#!/bin/bash
set -e

count=3
ami=ami-0a49b025fffbbdac6
instance_type=i3.metal
security_group_ids=sg-0f8c8cb3d7124e05c
subnet_id=subnet-68491802
key_name=jayjeet2-frankfurt
chmod 400 "${key_name}.pem"

spawn_ec2_instances() {
    echo "[+] Launching $count ec2 instances"
    aws ec2 run-instances \
        --image-id $ami \
        --count $count \
        --instance-type $instance_type	 \
        --key-name $key_name \
        --security-group-ids $security_group_ids \
        --subnet-id $subnet_id

    sleep 60

    echo "[+] Gathering Public and Private IPs "
    echo " " > public_ips.txt
    echo " " > private_ips.txt
    aws ec2 describe-instances --filters Name=key-name,Values=$key_name --output text --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" > public_ips.txt
    aws ec2 describe-instances --filters Name=key-name,Values=$key_name --output text --query "Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress" > private_ips.txt
}

do_ssh() {
    ssh -i "${key_name}.pem" ubuntu@$1 $2
}

do_scp() {
    scp -i "${key_name}.pem" $1 ubuntu@$2:$3
}

setup_passwordless_ssh() {
    do_ssh $1 "ssh-keygen -t rsa"
    do_ssh $1 "cat ~/.ssh/id_rsa.pub" > key.pub
}

authorize_keys() {
    cat key.pub | do_ssh $1 "cat - >> ~/.ssh/authorized_keys"
}

prepare_ec2_instances() {
    aws ec2 describe-instances --filters Name=key-name,Values=$key_name --output text --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" > public_ips.txt
    aws ec2 describe-instances --filters Name=key-name,Values=$key_name --output text --query "Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress" > private_ips.txt
    
    echo "[+] Preparing ec2 instances"
    ip=($(cat public_ips.txt))
    client=${ip[0]}
    server=${ip[1]}

    setup_passwordless_ssh $client
    for host in "${ip[@]}"
    do
        authorize_keys $host
    done

    echo "[+] Uncluttering node"
    do_ssh $client "rm -rf *.txt"
    do_ssh $client "rm -rf *.sh"
    do_ssh $client "rm -rf *.cc"
    
    echo "[+] Installing dependencies"
    do_ssh $server "sudo apt-get update"
    do_ssh $server "sudo apt-get install -y python3 python3-pip fio"

    echo "[+] Copying public and private IPs to client instance"
    do_scp public_ips.txt $client /home/ubuntu 
    do_scp private_ips.txt $client /home/ubuntu 

    echo "[+] Copying scripts to the client instance"
    do_scp bench.cc $client /home/ubuntu 
    do_scp deploy_ceph.sh $client /home/ubuntu 
    do_scp deploy_skyhook.sh $client /home/ubuntu 
    do_scp deploy_data.sh $client /home/ubuntu
    do_scp bench.sh $client /home/ubuntu 
    
    echo "[+] Copying scripts to the server instance"
    do_scp preconditioning/run.py $server /home/ubuntu
    do_scp preconditioning/template.fio $server /home/ubuntu

    printf "\n\n\n"
    echo "ssh -i '$key_name.pem' ubuntu@${client}"
}

case "$1" in
    -s|--spawn)
    spawn_ec2_instances
    prepare_ec2_instances
    ;;
    -p|--prepare)
    prepare_ec2_instances
    ;;
    *)
    echo "Usage: (-s|--spawn) (-p|--prepare)"
    exit 0
    ;;
esac

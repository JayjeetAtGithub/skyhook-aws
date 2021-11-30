#!/bin/bash
set -e

count=4
instance_type=i3.2xlarge
security_group_ids=sg-0bfc68da558cedfc3
subnet_id=subnet-cf4671ee
key_name=jayjeet2

spawn_ec2_instances() {
    echo "[+] Launching $count ec2 instances"
    aws ec2 run-instances \
        --image-id ami-083654bd07b5da81d \
        --count $count \
        --instance-type $instance_type	 \
        --key-name $key_name \
        --security-group-ids $security_group_ids \
        --subnet-id $subnet_id

    sleep 60

    echo "[+] Gathering Public and Private IPs "
    aws ec2 describe-instances --output text --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" > public_ips.txt
    aws ec2 describe-instances --output text --query "Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress" > private_ips.txt
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
    echo "[+] Preparing ec2 instances"
    ip=($(cat public_ips.txt))
    client=${ip[0]}

    setup_passwordless_ssh $client
    for host in "${ip[@]}"
    do
        authorize_keys $host
    done

    echo "[+] Uncluttering node"
    do_ssh $client "rm -rf *.txt"
    do_ssh $client "rm -rf *.sh"
    do_ssh $client "rm -rf *.cc"

    echo "[+] Copying public and private IPs to client instance"
    do_scp public_ips.txt $client /home/ubuntu 
    do_scp private_ips.txt $client /home/ubuntu 

    echo "[+] Copying scripts to the client instance"
    do_scp bench.cc $client /home/ubuntu 
    do_scp deploy_ceph.sh $client /home/ubuntu 
    do_scp deploy_skyhook.sh $client /home/ubuntu 
    do_scp bench.sh $client /home/ubuntu 

    printf "\n\n\n"
    echo "ssh -i '$key_name.pem' ubuntu@${ip[0]}"
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

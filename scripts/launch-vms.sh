#!/bin/bash
set -e

count=$2

spawn_ec2_instances() {
    echo "[+] Launching client ec2 instance"
    aws ec2 run-instances \
        --image-id ami-083654bd07b5da81d \
        --count 1 \
        --instance-type i3.2xlarge \
        --key-name jayjeet \
        --security-group-ids sg-0bfc68da558cedfc3 \
        --subnet-id subnet-cf4671ee

    echo "[+] Launching MON ec2 instances"
    aws ec2 run-instances \
        --image-id ami-083654bd07b5da81d \
        --count 3 \
        --instance-type i3.2xlarge \
        --key-name jayjeet \
        --security-group-ids sg-0bfc68da558cedfc3 \
        --subnet-id subnet-cf4671ee

    echo "[+] Launching $count OSD ec2 instances"
    aws ec2 run-instances \
        --image-id ami-083654bd07b5da81d \
        --count $count \
        --instance-type i3.2xlarge \
        --key-name jayjeet \
        --security-group-ids sg-0bfc68da558cedfc3 \
        --subnet-id subnet-cf4671ee

    sleep 60

    echo "[+] Gathering Public and Private IPs "
    aws ec2 describe-instances --output text --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" > public_ips.txt
    aws ec2 describe-instances --output text --query "Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress" > private_ips.txt
}

do_ssh() {
    ssh -i "amazon.pem" ubuntu@$1 $2
}

do_scp() {
    scp -i "amazon.pem" $1 ubuntu@$2:$3
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

    printf "\n\n\n"
    echo "ssh -i 'amazon.pem' ubuntu@${ip[0]}"
}

case "$1" in
    -s|--spawn)
    spawn_ec2_instances
    ;;
    -p|--prepare)
    prepare_ec2_instances
    ;;
    *)
    echo "Usage: (-s|--spawn) (-sk|--skip)"
    exit 0
    ;;
esac

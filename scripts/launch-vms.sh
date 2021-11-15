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

prepare_ec2_instances() {
    echo "[+] Preparing ec2 instances"
    ip=($(cat public_ips.txt))
    echo "Client node: ${ip[0]}"

    echo "[+] Uncluttering node"
    ssh -i "amazon.pem" ubuntu@${ip[0]} "rm -rf *.txt"
    ssh -i "amazon.pem" ubuntu@${ip[0]} "rm -rf *.sh"
    ssh -i "amazon.pem" ubuntu@${ip[0]} "rm -rf *.pem"

    echo "[+] Copying PEM file to client instance"
    scp -i "amazon.pem" amazon.pem ubuntu@${ip[0]}:/home/ubuntu 

    echo "[+] Copying public and private IPs to client instance"
    scp -i "amazon.pem" public_ips.txt ubuntu@${ip[0]}:/home/ubuntu 
    scp -i "amazon.pem" private_ips.txt ubuntu@${ip[0]}:/home/ubuntu 

    echo "[+] Copying scripts to the client instance"
    scp -i "amazon.pem" deploy_ceph.sh ubuntu@${ip[0]}:/home/ubuntu 
    scp -i "amazon.pem" deploy_skyhook.sh ubuntu@${ip[0]}:/home/ubuntu 
    scp -i "amazon.pem" passwordless.sh ubuntu@${ip[0]}:/home/ubuntu 
    ssh -i "amazon.pem" ubuntu@${ip[0]} "chmod +x *.sh"

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

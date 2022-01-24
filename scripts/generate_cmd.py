import os

if __name__ == "__main__":
    private_ip_file = "private_ips.txt"
    with open(private_ip_file, 'r') as f:
        ips = f.read()

    ips = ips.rstrip().split('\t')   

    cmd = "./deploy_ceph.sh "

    hostnames = list()
    for ip in ips:
        hostnames.append("ip-"+ip.replace(".",'-'))

    cmd = "./deploy_ceph.sh " + ','.join(hostnames[1:4]) + " " + ','.join(hostnames[4:]) + " " + hostnames[1] + " " + hostnames[2]
    # cmd += " /dev/nvme0n1,/dev/nvme1n1,/dev/nvme2n1,/dev/nvme3n1 "
    cmd += " /dev/nvme0n1,/dev/nvme1n1,/dev/nvme2n1,/dev/nvme3n1,/dev/nvme4n1,/dev/nvme5n1,/dev/nvme6n1,/dev/nvme7n1 "
    cmd += " 3 1024 64 "
    print(cmd)

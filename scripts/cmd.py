import os

if __name__ == "__main__":
    with open("private_ips.txt", "r") as f:
        data = f.read()
    ips = data.split("\t")
    hostnames = []
    for ip in ips:
        ip = ip.strip()
        hostnames.append("ip-" + ip.replace(".", "-"))

    mons_ips = ",".join(hostnames[1:4])
    mds_ips = ",".join(hostnames[1:2])
    mgr_ips = hostnames[2]
    osds_ips = ",".join(hostnames[1:])

    print("./deploy_ceph.sh " + mons_ips + " " + osds_ips + " " + mds_ips + " " + mgr_ips + " /dev/nvme0n1 " + "3")
    
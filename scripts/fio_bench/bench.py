import os
import sys

if __name__ == '__main__':
    client = str(sys.argv[1])
    template = "bench.fio.template"
    key = "../jayjeet2-frankfurt.pem"

    with open(template, "r") as f:
        data = f.read()

    workloads = ["write", "read", "randwrite", "randread"]
    drives = ["/dev/nvme1n1", "/dev/nvme2n1", "/dev/nvme3n1", "/dev/nvme4n1",
                "/dev/nvme5n1", "/dev/nvme6n1", "/dev/nvme7n1", "/dev/nvme8n1"]

    for workload in workloads: 
        job_string = ""   
        for drive in drives:
            job_string += """
[{}]
filename={}
""".format(drive.split("/")[2], drive, drive.split("/")[2], workload)

        with open(workload + ".fio", "w") as f:
            f.write(data.replace("%workload%", workload))
            f.write("\n")
            f.write(job_string)

    os.system(f"ssh -i '{key}' ubuntu@{client} rm -rf fio_bench/")
    for workload in workloads:
        os.system(f"ssh -i '{key}' ubuntu@{client} mkdir -p fio_bench/fio_job_files")
        os.system(f"ssh -i '{key}' ubuntu@{client} mkdir -p fio_bench/fio_result")
        os.system(f"scp -i '{key}' {workload}.fio ubuntu@{client}:/home/ubuntu/fio_bench/fio_job_files")
        os.system(f"ssh -i '{key}' ubuntu@{client} sudo fio fio_bench/fio_job_files/{workload}.fio")

    for workload in workloads:
        for i in range(2, 9):
            os.system(f"ssh -i '{key}' ubuntu@{client} rm -rf {workload}.results_*.{i}.log")

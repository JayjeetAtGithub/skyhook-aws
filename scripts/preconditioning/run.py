import os

def run_raw_command(command, env=None):
    return os.system(" ".join(command))

if __name__ == "__main__":
    devices = [
        "/dev/nvme1n1", 
        "/dev/nvme2n1", 
        "/dev/nvme3n1", 
        "/dev/nvme4n1", 
        "/dev/nvme5n1", 
        "/dev/nvme6n1", 
        "/dev/nvme7n1", 
        "/dev/nvme8n1"
    ]

    for device in devices:
        with open('template.fio', 'r') as f:
            template = f.read()
            template = template.replace("%device%", device)

        device = os.path.basename(device)

        with open('job_{}.fio'.format(device), 'w') as f:
            f.write(template)

        cmd = ['sudo', 'fio', 'job_{}.fio'.format(device), '--output-format=json', '--output=job_{}.json'.format(device)]
        run_raw_command(cmd)

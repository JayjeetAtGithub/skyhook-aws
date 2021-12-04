import os
import sys
import subprocess

def run_raw_command(command, env=None):
    result = subprocess.run(
        command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env
    )
    if result.returncode > 0 or (len(str(result.stderr)) > 3):
        stdout = result.stdout.decode("UTF-8").strip()
        stderr = result.stderr.decode("UTF-8").strip()
        print(f"\nAn error occurred: {stderr} - {stdout}")
        sys.exit(1)

    return result

if __name__ == "__main__":
    device = sys.argv[1]
    with open('template.fio', 'r') as f:
        template = f.read()
        template.replace("%device%", device)

    device = os.path.basename(device)

    with open('job_{}.fio'.format(device), 'w') as f:
        f.write(template)

    cmd = ['fio', 'job_{}.fio'.format(device), '--output-format=json', '--output=job_{}.json'.format(device)]
    result = run_raw_command(cmd)
    print(result)

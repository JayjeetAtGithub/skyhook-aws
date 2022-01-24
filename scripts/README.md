1. 
```
./launch-vms.sh -s
```

2. 
```
screen -dmSL workstuff python3 run.py
```

3. 
```
cat screenlog.0
```

4. 

dcfldd if=/dev/zero of=/dev/nvme1n1 of=/dev/nvme2n1 of=/dev/nvme3n1 of=/dev/nvme4n1 of=/dev/nvme5n1 of=/dev/nvme6n1 of=/dev/nvme7n1 of=/dev/nvme8n1 


# Observations

After starting to write to the disk, after sometime the disk steady states itself from 2.8GB/s to like 2GB/s. OSDs keep writing event after client stops writing data. 
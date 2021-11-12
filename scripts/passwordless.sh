#! /bin/bash

filename="id_rsa"
path="$HOME/.ssh"
username="ubuntu"
hostnames=($(cat private_ips.txt))

cat > ~/.ssh/config << EOF
Host *
    StrictHostKeyChecking no
EOF

# Generate rsa files
if [ -f $path/$filename ]
then
    echo "RSA key exists on $path/$filename, using existing file"
else
    ssh-keygen -t rsa -f "$path/$filename"
    echo RSA key pair generated
fi

for hostname in "${hostnames[@]}"
do
# Avoid duplicate keys in authorized_keys, user can run this all the time
echo "We need to log into $hostname as $username to set up your public key (hopefully last time you'll use password from this computer)"
cat "$path/$filename.pub" | ssh -i "jayjeet.pem" "$hostname" -l "$username" ' [ -d ~/.ssh ] || \
                                                             mkdir -p ~/.ssh ; \
                                                             cat > ~/.ssh/KEY ; \
                                                             KEY=$(cat ~/.ssh/KEY) ; \
                                                             export KEY ; \
                                                             grep -q "$KEY" ~/.ssh/authorized_keys || \
                                                             cat ~/.ssh/KEY >> .ssh/authorized_keys ; \
                                                             chmod 700 ~/.ssh ; \
                                                             chmod 600 ~/.ssh/authorized_keys ;
                                                             rm ~/.ssh/KEY'
status=$?

if [ $status -eq 0 ]
then
    echo "Set up complete, try to ssh to $hostname now"
else
    echo "An error has occured"
    exit 255
fi
done
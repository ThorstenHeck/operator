# Ansible-operator Docker Container

This project aims to enable KraB project member to run ansible against our infrastructure in a standarized way.  
Its intended as a quick helper, not to exemplify a structure.

## Installation


```
git clone https://abc && cd abc
docker build .
```


### Network Helper

To overcome network issues, I added an example inventory file that shows how to run ansible via a ssh jump host.  

The example uses stdio forwarding from the Tool Server 10.252.25.35 and intends to do exactly 1 hop, if you need to recursively chain jump hosts you could overwrite the ssh config file to something like that:  

```
cat <<EOF > .ssh/config
Host jump-1
        Hostname 10.252.24.35
        User jump-1
        IdentityFile /home/ansible/.ssh/id_ed25519
        Port 22
 
Host jump-2
        Hostname 10.252.26.2
        User root
        IdentityFile /home/ansible/.ssh/id_rsa
        Port 22
        ProxyCommand ssh -W %h:%p -q jump-1
 
Host target-1
        Hostname 10.252.27.2
        User root
        IdentityFile /home/ansible/.ssh/id_ed25519
        Port 22
        ProxyCommand ssh -W %h:%p -q jump-2     
EOF
```

Keep in mind, that you need to take care about your ssh-keys. You can directly mount your ssh-agent to make it seemless to your local experience.  
If that does not suite your needs, copy the desired ssh-keys into the .ssh directory, build the image and manage the ssh key inside the container manually. 
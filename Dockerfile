FROM alpine:3.17
LABEL description="Ansible 7.4.0, Terraform 1.4.5 and Packer 1.8.6 on Alpine 3.17 and Python 3.10"
ARG ANSIBLE_VERSION=7.4.0
ARG TERRAFORM_VERSION=1.4.5
ARG PACKER_VERSION=1.8.6

ARG SSH_PRIV_KEY=
ARG SSH_PUB_KEY=

ENV USER_ID=2001
ENV GROUP_ID=2001
ENV USER_NAME=ansible
ENV GROUP_NAME=ansible

ENV GROUP_ID_SUDO=110
ENV GROUP_NAME_SUDO=sudo

# install terraform 
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN mv terraform /usr/bin/terraform

# install packer 
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip && rm packer_${PACKER_VERSION}_linux_amd64.zip
RUN mv packer /usr/bin/packer

# install ansible 
RUN /bin/sh -c set -e && \
    apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache openssh sudo gcc make python3 python3-dev openssl-dev \
    py3-cffi py3-bcrypt py-cryptography py3-pynacl py3-pip bash curl git && \
    pip3 install --no-cache-dir pip && \
    pip3 install --no-cache-dir ansible==${ANSIBLE_VERSION} && \
    addgroup -g $GROUP_ID $GROUP_NAME && \
    adduser --uid $USER_ID --disabled-password --home /home/ansible \
    --shell /bin/bash --ingroup $GROUP_NAME $USER_NAME  && \
    mkdir -p /home/ansible/.ssh && chown ansible:ansible -R /home/ansible

WORKDIR /home/ansible

# sudo for ansible user
RUN addgroup -g $GROUP_ID_SUDO $GROUP_NAME_SUDO && \
    addgroup -S $USER_NAME $GROUP_NAME_SUDO && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ansible
COPY ./requirements.yml /home/ansible
COPY ./ssh /home/ansible/.ssh
RUN ansible-galaxy collection install -r requirements.yml

CMD [ "/bin/sh"]
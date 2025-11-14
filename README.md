# ansible_docker_windows
Gerenciando Windows com Ansible via Docker e replicando no Active Directory por GPO.

O Ansible é uma ferramenta de automação que permite gerenciar servidores e estações de trabalho de forma centralizada. Embora seja mais comum em ambientes Linux, ele também pode ser usado para controlar máquinas Windows integradas ao Active Directory (AD).

O Ansible funciona como um orquestrador central, usando o AD para autenticação e WinRM para comunicação, garantindo que a administração de máquinas Windows seja tão automatizada e eficiente quanto em ambientes Linux.

# Deploy

**Instale o Docker:**

Debian
````
sudo apt install docker.io
sudo systemctl enable --now docker
````

CentOS
````
sudo yum install docker
sudo systemctl enable --now docker
````

Imagem Docker: https://hub.docker.com/r/ansible/ansible



---------------------------


#Docker

Dockerfile
````
FROM python:3.11-slim
ENV DEBIAN_FRONTEND=noninteractive PIP_DISABLE_PIP_VERSION_CHECK=1 PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client sshpass iputils-ping dnsutils ca-certificates git vim \
    krb5-user krb5-config libsasl2-modules-gssapi-mit \
    gcc build-essential libkrb5-dev python3-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    "ansible==9.*" \
    ansible-lint \
    "pywinrm[kerberos,credssp]" \
    paramiko jmespath netaddr

RUN apt-get purge -y gcc build-essential python3-dev libkrb5-dev && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /ansible
CMD ["bash"]
````

![ls](imagens/ls.png)

````
/
├── Ansible
│   ├── Dockerfile
│   └── playbooks
│   │   ├── create_vlan.yml 
│   │   ├── ping_icmp.yml
│   │   └──── inventory
│   │        └──── host.ini
````

Buildando a imagem docker:
````
docker build -t ansible:latest .
````

Subindo o container:
`````
docker run --rm -it   -v "$PWD":/ansible:Z   -v "$HOME/.ssh":/root/.ssh:ro,Z   -v /etc/krb5.conf:/etc/krb5.conf:ro,Z   -w /ansible   --name ansible   ansible:latest bash
````

![ls](imagens/docker_run.png)


#docker ps
![ls](imagens/docker_run.png)


Exportando "KRB5CCNAME=FILE:/tmp/krb5cc_$(id -u)" para força o Kerberos a usar um arquivo como cache:
````
export KRB5CCNAME=FILE:/tmp/krb5cc_$(id -u); mkdir -p /etc/krb5.conf.d
````

Criando um ticket para o Kerberos se autenticar no domínio:
````
kinit usuario@dominio.local
````

Testando conexão de um playbook para teste icmp, em --limit deixe o endereço do host que foi setado dentro de playbooks/host.ini.
````
ansible -i playbooks/host.ini windows -m ansible.windows.win_ping --limit HOST.dominio.local
````

Para testa a conexão, podemos criar uma regra de Firewall nos hosts windows

````
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -Enabled True -Action Allow -Profile Any
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress Any
````


# GPO


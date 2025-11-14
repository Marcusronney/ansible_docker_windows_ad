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
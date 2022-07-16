FROM debian:bullseye
ARG ARG_POWER_USER=salt
ARG ARG_PU_PWD=salt
RUN apt-get -y update && apt-get -y upgrade && apt-get -y --no-install-recommends install procps sudo init gnupg gnupg2 gnupg1 python3 python3-pip openssl curl net-tools nano
RUN useradd --create-home --home-dir /home/${ARG_POWER_USER} --shell /bin/bash --system --uid 1001 --gid root --groups sudo --password "$(openssl passwd -6 ${ARG_PU_PWD})" ${ARG_POWER_USER}
USER ${ARG_POWER_USER}
WORKDIR /home/${ARG_POWER_USER}
RUN echo ${ARG_PU_PWD} | sudo -S sh -c "curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/debian/11/amd64/latest/salt-archive-keyring.gpg"
RUN echo ${ARG_PU_PWD} | sudo -S sh -c "echo 'deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/debian/11/amd64/latest bullseye main' | tee /etc/apt/sources.list.d/salt.list"
RUN echo ${ARG_PU_PWD} | sudo -S apt-get update -y
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-master
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-minion
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-ssh
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-syndic
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-cloud
RUN echo ${ARG_PU_PWD} | sudo -S apt-get install -y salt-api
USER root
# Salt-Master config
RUN sh -c "echo 'instance: 0.0.0.0' | tee -a /etc/salt/master.d/master.conf"
EXPOSE 4505
EXPOSE 4506
EXPOSE 8000
CMD [ "/bin/bash", "-c", "/usr/bin/python3 /usr/bin/salt-master -d && /usr/bin/tail -f /dev/null" ]
VOLUME ["/etc/salt/"]

FROM majo418/ubuntudind:latest

LABEL version="1.0" maintainer="Majo Richter <majo418@coreunit.net>"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root
USER root

# upgrade and unminimize
RUN apt-get update && \
    apt-get install -yq apt-utils && \
    yes | unminimize - && \
    sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get full-upgrade -y && \
    apt-get install -y \
        sudo bash adduser \
        nano vim git wget curl screen iptables supervisor \
        ca-certificates openssh-client apt-transport-https \
        gnupg software-properties-common && \
    sudo apt-get autoremove -y

# install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce

# install node and npm
RUN apt-get install -y nodejs npm && \
    npm i -g n@latest && \
    n 16 && \ 
    export PATH="/usr/local/bin/node:$PATH" && \
    npm i -g npm@latest && \
    npm i -g nodemon@latest && \
    npm up -g

# setup "codec" user
RUN chmod -R 770 /root && \
    chown -hR root:sudo /root && \
    passwd -d root && \
    groupadd -g 10000 codec && \
    useradd -o \
    -mk /etc/skel \
    -d /home/codec \
    -s /bin/bash \
    -u 0 \
    -g 0 \
    -c "Default codec user" \
    codec \
    && \
    usermod -G root codec && \
    usermod -G sudo codec && \
    usermod -G codec codec && \
    chmod -R 770 /home/codec && \
    chown -hR codec:codec /home/codec && \
    passwd -d codec && \
    su codec && \
    mkdir -p /home/codec/.bin && \
    echo -n "PATH=\"/home/codec/ws/.codec/bin:/home/codec/.codec/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"" > /etc/environment && \
    echo "\nsource /home/codec/.codec/bashinit.sh\ncd\n" >> /home/codec/.bashrc && \
    echo "\ncodec     ALL=(ALL:ALL) ALL\n" >> /etc/sudoers && \
    chmod +x /etc/environment && \
    mkdir -p /home/codec/ws && \
    echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && \
    sysctl -p
WORKDIR /home/codec
USER codec

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=3.12.0

# copy start files
COPY ./codec /home/codec/.codec

VOLUME /home/codec/ws
EXPOSE 8080/tcp

CMD [ "su", "codec", "-c", "/home/codec/.codec/docker-entrypoint.sh" ]


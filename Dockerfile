FROM python:3-slim-buster

# Install all the required packages
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# install required packages
RUN apt-get update && apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free && \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    # this package is required to fetch "contents" via "TLS"
    apt-transport-https \
    # install coreutils
    coreutils jq pv gcc g++ \
    # install encoding tools
    ffmpeg aria2 curl gnupg2 wget \
    # miscellaneous
    neofetch python3-dev git bash build-essential nodejs npm ruby \
    python-minimal locales python-lxml gettext-base xz-utils \
    # install extraction tools
    p7zip-full p7zip-rar rar unrar zip unzip \
    # miscellaneous helpers
    megatools mediainfo && \
    # clean up the container "layer", after we are done
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV LANG C.UTF-8
# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive
# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

#rclone 
RUN curl https://rclone.org/install.sh | bash

# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# mega cmd
RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb && rm megacmd.deb

# Install dovi_tool
RUN wget -P /tmp https://github.com/quietvoid/dovi_tool/releases/download/1.5.6/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN rm /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz

COPY requirements.txt .
RUN python -m pip install --upgrade pip
RUN pip3 install -U pip
RUN pip3 install --no-cache-dir -r requirements.txt

# Copies config(if it exists)
COPY . .

RUN cp .up/dl .up/up .up/0 /usr/local/bin/ && chmod +x /usr/local/bin/dl /usr/local/bin/up /usr/local/bin/0

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm i -g npm

# Install requirements and start the bot
RUN npm install

CMD ["node", "server"]

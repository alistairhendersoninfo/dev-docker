FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    vim \
    neovim \
    gnupg \
    ca-certificates \
    wget \
    unzip \
    nodejs \
    npm \
    tmux \
    zsh \
    net-tools \
    iputils-ping \
    dnsutils \
    netcat \
    telnet \
    traceroute \
    nmap \
    tcpdump \
    iotop \
    sysstat \
    procps \
    lsof \
    strace \
    ltrace \
    && apt-get clean

# Install Cursor CLI
RUN curl https://cursor.com/install -fsS | bash

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash
RUN npm install -g opencode-ai

# Install Claude CLI
RUN curl -fsSL https://claude.ai/install | bash

# Install essential development tools
# (Node.js and Python tools will be installed per-project as needed)

# Install essential lightweight CLI tools
RUN apt-get update && apt-get install -y \
    jq \
    yq \
    xmlstarlet \
    ripgrep \
    fd-find \
    bat \
    exa \
    fzf \
    tree \
    htop \
    ncdu \
    tldr \
    && apt-get clean

# Install additional useful tools
RUN npm install -g \
    yaml \
    xml2js \
    csv-parser \
    json \
    && npm cache clean --force

# Install additional lightweight system tools
RUN apt-get update && apt-get install -y \
    moreutils \
    parallel \
    expect \
    && apt-get clean

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install database tools
# (Database CLI tools will be installed per-project as needed)

# Create developer user and add to sudo group (sudo group already exists in Ubuntu)
RUN useradd -m -s /bin/bash -G sudo developer

# Create SSH directory and set permissions
RUN mkdir -p /home/developer/.ssh && \
    chown developer:developer /home/developer/.ssh && \
    chmod 700 /home/developer/.ssh

# Create authorized_keys file (will be populated at runtime via volume mount)
RUN touch /home/developer/.ssh/authorized_keys && \
    chown developer:developer /home/developer/.ssh/authorized_keys && \
    chmod 600 /home/developer/.ssh/authorized_keys

# Configure SSH
RUN mkdir /var/run/sshd && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config

# Set default shell to zsh for developer user
RUN chsh -s /usr/bin/zsh developer

# Copy configuration files
COPY tmux.conf /home/developer/.config/tmux/tmux.conf
COPY zshrc /home/developer/.zshrc

# Set ownership of config files
RUN chown -R developer:developer /home/developer/.config && \
    chown developer:developer /home/developer/.zshrc

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

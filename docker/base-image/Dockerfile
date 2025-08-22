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

# Install essential lightweight CLI tools (available in Ubuntu repos)
RUN apt-get update && apt-get install -y \
    jq \
    xmlstarlet \
    fzf \
    tree \
    htop \
    ncdu \
    && apt-get clean

# Install yq manually (not in Ubuntu repos)
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod a+x /usr/local/bin/yq

# Install modern CLI tools manually with proper version detection and cleanup
RUN set -eux; \
    # Install ripgrep
    RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+'); \
    wget -qO /tmp/ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_${RIPGREP_VERSION}-1_amd64.deb"; \
    dpkg -i /tmp/ripgrep.deb; \
    rm -f /tmp/ripgrep.deb; \
    # Install fd-find
    FD_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+'); \
    wget -qO /tmp/fd.deb "https://github.com/sharkdp/fd/releases/latest/download/fd_${FD_VERSION}_amd64.deb"; \
    dpkg -i /tmp/fd.deb; \
    rm -f /tmp/fd.deb; \
    # Install bat
    BAT_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+'); \
    wget -qO /tmp/bat.deb "https://github.com/sharkdp/bat/releases/latest/download/bat_${BAT_VERSION}_amd64.deb"; \
    dpkg -i /tmp/bat.deb; \
    rm -f /tmp/bat.deb; \
    # Install exa
    EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+'); \
    wget -qO /tmp/exa.deb "https://github.com/ogham/exa/releases/latest/download/exa_${EXA_VERSION}_amd64.deb"; \
    rm -f /tmp/exa.deb; \
    # Clean up any remaining temp files and apt cache
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install tldr manually (not in Ubuntu repos)
RUN npm install -g tldr

# Install additional useful tools
RUN npm install -g \
    yaml \
    xml2js \
    csv-parser \
    json \
    && npm cache clean --force \
    && rm -rf /root/.npm /tmp/npm-*

# Install additional lightweight system tools
RUN apt-get update && apt-get install -y \
    moreutils \
    parallel \
    expect \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

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

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential system packages first
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
    tar \
    gzip \
    && apt-get clean

# Install Node.js 18+ from official source
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install essential lightweight CLI tools (available in Ubuntu repos)
RUN apt-get update && apt-get install -y \
    jq \
    xmlstarlet \
    fzf \
    tree \
    htop \
    ncdu \
    moreutils \
    parallel \
    expect \
    && apt-get clean

# Install essential CLI tools
RUN set -eux; \
    # Install Cursor CLI
    curl -fsSL https://cursor.com/install | bash; \
    # Install OpenCode CLI
    curl -fsSL https://opencode.ai/install | bash; \
    npm install -g opencode-ai; \
    # Install Claude CLI
    curl -fsSL https://claude.ai/install | bash; \
    # Install yq manually (not in Ubuntu repos)
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod a+x /usr/local/bin/yq; \
    # Install tldr manually (not in Ubuntu repos)
    npm install -g tldr; \
    # Install additional useful npm packages
    npm install -g yaml xml2js csv-parser json && \
    npm cache clean --force && \
    rm -rf /root/.npm /tmp/npm-*; \
    # Clean up
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install AI debugging tools
RUN set -eux; \
    # Install ripgrep (fast grep replacement for AI debugging)
    wget -qO /tmp/ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1_amd64.deb" && \
    dpkg -i /tmp/ripgrep.deb && \
    rm -f /tmp/ripgrep.deb; \
    # Install fd-find (fast find replacement for AI debugging)
    wget -qO /tmp/fd.deb "https://github.com/sharkdp/fd/releases/download/v10.2.0/fd_10.2.0_amd64.deb" && \
    dpkg -i /tmp/fd.deb && \
    rm -f /tmp/fd.deb; \
    # Install bat (better cat with syntax highlighting for AI debugging)
    wget -qO /tmp/bat.deb "https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb" && \
    dpkg -i /tmp/bat.deb && \
    rm -f /tmp/bat.deb; \
    # Install exa (better ls replacement for AI debugging) - extract from zip
    wget -qO /tmp/exa.zip "https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip" && \
    unzip -j /tmp/exa.zip "bin/exa" -d /tmp/ && \
    mv /tmp/exa /usr/local/bin/exa && \
    chmod +x /usr/local/bin/exa && \
    rm -f /tmp/exa.zip; \
    # Clean up any remaining temp files and apt cache
    rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Oh My Zsh (optional)
RUN (sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended) || echo "Oh My Zsh installation failed, continuing..."

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

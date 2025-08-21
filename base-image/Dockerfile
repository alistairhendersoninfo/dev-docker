FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    jq \
    git \
    vim \
    neovim \
    gnupg \
    ca-certificates \
    wget \
    unzip \
    python3 \
    python3-pip \
    nodejs \
    npm \
    htop \
    tree \
    tmux \
    fzf \
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
RUN curl -L https://cursor.sh/install.sh | sh

# Install OpenCode CLI
RUN npm install -g @opencode/cli

# Install essential development tools
RUN npm install -g \
    typescript \
    ts-node \
    @types/node \
    eslint \
    prettier \
    nodemon

# Install Python development tools
RUN pip3 install \
    black \
    flake8 \
    mypy \
    pytest \
    yq \
    xmltodict

# Install Rust (for modern CLI tools)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install essential Rust-based CLI tools
RUN cargo install \
    bat \
    exa \
    fd-find \
    ripgrep \
    tokei \
    starship \
    zoxide \
    bottom \
    du-dust \
    procs \
    sd \
    tealdeer \
    xh \
    oha \
    bandwhich

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install database CLI tools
RUN npm install -g \
    @databases/cli \
    prisma \
    typeorm \
    sequelize-cli \
    knex \
    mongosh

# Install database GUI alternatives
RUN npm install -g \
    @dbgate/cli \
    @dbgate/desktop

# Create developer user and sudo group
RUN groupadd -r sudo && \
    useradd -m -s /bin/bash -G sudo developer

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

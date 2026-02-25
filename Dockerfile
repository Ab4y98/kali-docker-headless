FROM kalilinux/kali-rolling

LABEL maintainer="Daniel Abay" \
      description="Kali Linux with commonly used security tools in a Docker container"

ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/zsh \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    PATH="/usr/local/bin:${PATH}"

# Update base system and install tools
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends \
        kali-linux-headless \
        sudo \
        net-tools iproute2 iputils-ping traceroute \
        nmap metasploit-framework \
        sqlmap hydra john nikto dirb \
        gobuster wfuzz ffuf eyewitness netexec enum4linux\
        aircrack-ng \
        curl wget git vim nano tmux zsh \
        python3 python3-pip python3-venv golang-go pipx \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install knock-subdomains via pipx so its binary is on PATH
RUN pipx install knock-subdomains

# Install ProjectDiscovery tools using pdtm
RUN export GO111MODULE=on && \
    go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest && \
    /root/go/bin/pdtm -install-all && \
    ln -sf /root/go/bin/* /usr/local/bin/ && \
    rm -f /usr/bin/httpx || true && \
    ln -sf /root/go/bin/httpx /usr/local/bin/httpx

# Install seclists
RUN git clone https://github.com/Ab4y98/seclists.git /usr/share/seclists

WORKDIR /root

# Default to an interactive zsh shell that also sources .bashrc if present
CMD ["/bin/zsh", "-lc", "[ -f ~/.bashrc ] && source ~/.bashrc; exec zsh -i"]



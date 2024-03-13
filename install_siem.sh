#!/bin/bash

GROUP='Linux'
CLIENTE='LAB-CONTEGO'
SIEM_GROUPS="${GROUP},${CLIENTE}"
SERVER=siem.contego.com.br


# Detect the OS
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Ubuntu 20.04 & 22.04
if [[ $OS == *"Ubuntu"* ]]; then
    #SIEM Ubuntu
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP=${SIEM_GROUPS} dpkg -i ./wazuh-agent_4.7.0-1_amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install sysmonforlinux -y

# Debian 11
elif [[ $OS == *"Debian"* ]]; then
    #SIEM Ubuntu
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' dpkg -i ./wazuh-agent_4.7.0-1_amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
    sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    wget -q https://packages.microsoft.com/config/debian/11/prod.list
    sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
    sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
    sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt-get update
    sudo apt-get install apt-transport-https -y
    sudo apt-get update
    sudo apt-get install sysmonforlinux -y

# Fedora 36
elif [[ $OS == *"Fedora"* ]]; then
    #SIEM RPM
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo wget -q -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/fedora/36/prod.repo
    sudo dnf install sysmonforlinux

# CentOS
elif [[ $OS == *"CentOS"* ]]; then
    #SIEM RPM
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo wget -q -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/rhel/8/prod.repo
    sudo dnf install sysmonforlinux

# RHEL 8
elif [[ $OS == *"Red Hat"* ]]; then
    #SIEM RPM
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo wget -q -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/rhel/8/prod.repo
    sudo dnf install sysmonforlinux

# RHEL 9
elif [[ $OS == *"Red Hat"* ]]; then
    #SIEM RPM
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo wget -q -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/rhel/9.0/prod.repo
    sudo dnf install sysmonforlinux

# openSUSE 15
elif [[ $OS == *"openSUSE"* ]]; then
    #SIEM RPM
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER=${SERVER} WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
    sudo systemctl daemon-reload
    sudo systemctl enable wazuh-agent
    sudo systemctl start wazuh-agent
    #Sysmon
    sudo zypper install libicu
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    wget -q https://packages.microsoft.com/config/opensuse/15/prod.repo
    sudo mv prod.repo /etc/zypp/repos.d/microsoft-prod.repo
    sudo chown root:root /etc/zypp/repos.d/microsoft-prod.repo
    sudo zypper install sysmonforlinux

else
    echo "Unsupported OS"
    exit 1
fi

# Install Sysmon
sudo sysmon -i

#configuração sysmon
sudo wget -O /opt/sysmon/config-custom.xml https://raw.githubusercontent.com/ContegoSecurity/SOC/main/sysmon/linux/sysmon-custom.xml
sudo sysmon -c /opt/sysmon/config-custom.xml

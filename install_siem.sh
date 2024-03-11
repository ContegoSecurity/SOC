#!/bin/bash

GROUP='Linux'
#Adicione os grupos de clientes neste array. O padrão é caixa alta
CLIENTS=("CONTEGO" "COOBRASTUR" "GEO" "LAB-CONTEGO" "TIROL")

#INPUT SERVIDOR SIEM
read -p "Digite o servidor SIEM: " SIEM_SERVER

if ping -c 1 "$SIEM_SERVER" >/dev/null; then
    echo "Servidor SIEM respondeu ao ping"
else
    echo "O servidor $SIEM_SERVER não está acesssível. Verifique se o nome ou ip está correto. Deseja continuar? "
    read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi

#INPUT NOME CLIENTE
read -p "Digite o nome do cliente: " siem_group

#converte para caixa alta
SIEM_GROUP=$(echo "$siem_group" | tr '[:lower:]' '[:upper:]')

#Verifica se o nome do cliente existe no array CLIENTS
found=0
for client in "${CLIENTS[@]}"; do
    if [ "$SIEM_GROUP" = "$client" ]; then
        found=1
        break
    fi
done

if [ $found -eq 0 ]; then
    echo "Cliente ${siem_group} não encontrado. Verifique se você digitou corretamente."
    exit 1
fi

#Adiciona Linux no grupo
SIEM_GROUPS="${GROUP},${SIEM_GROUP}"


#Verifica OS e instala o Wazuh e Sysmon.
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

# Ubuntu 20.04 & 22.04
if [[ $OS == *"Ubuntu"* ]]; then
    #SIEM Ubuntu
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' dpkg -i ./wazuh-agent_4.7.0-1_amd64.deb
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
    wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' dpkg -i ./wazuh-agent_4.7.0-1_amd64.deb
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
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
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
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
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
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
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
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
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
    curl -o wazuh-agent-4.7.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.0-1.x86_64.rpm && sudo WAZUH_MANAGER='${SIEM_SERVER}' WAZUH_AGENT_GROUP='${SIEM_GROUPS}' rpm -ihv wazuh-agent-4.7.0-1.x86_64.rpm
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

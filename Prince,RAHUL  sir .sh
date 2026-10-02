#!/bin/bash

# Rishikesh Cyber Police - Hound v0.2
# Authorized Cybersecurity Training Tool

trap 'printf "\n"; stop' 2


# ==============================
# Banner
# ==============================

banner() {
    clear

    printf '\n'

    printf '\e[1;96m'
    printf '       ██████╗ ██╗███████╗██╗  ██╗██╗██╗  ██╗███████╗███████╗██╗  ██╗\n'
    printf '       ██╔══██╗██║██╔════╝██║  ██║██║██║ ██╔╝██╔════╝██╔════╝██║  ██║\n'
    printf '       ██████╔╝██║███████╗███████║██║█████╔╝ █████╗  ███████╗███████║\n'
    printf '       ██╔══██╗██║╚════██║██╔══██║██║██╔═██╗ ██╔══╝  ╚════██║██╔══██║\n'
    printf '       ██║  ██║██║███████║██║  ██║██║██║  ██╗███████╗███████║██║  ██║\n'
    printf '       ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝\n'
    printf '\e[0m'

    printf '\n'

    printf '\e[1;91m'
    printf '        ██████╗██╗   ██╗██████╗ ███████╗██████╗ \n'
    printf '       ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗\n'
    printf '       ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝\n'
    printf '       ██║       ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗\n'
    printf '       ╚██████╗   ██║   ██║     ███████╗██║  ██║\n'
    printf '        ╚═════╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝\n'
    printf '\e[0m'

    printf '\n'

    printf '\e[1;93m'
    printf '       ██████╗  ██████╗ ██╗     ██╗ ██████╗███████╗\n'
    printf '       ██╔══██╗██╔═══██╗██║     ██║██╔════╝██╔════╝\n'
    printf '       ██████╔╝██║   ██║██║     ██║██║     █████╗  \n'
    printf '       ██╔═══╝ ██║   ██║██║     ██║██║     ██╔══╝  \n'
    printf '       ██║     ╚██████╔╝███████╗██║╚██████╗███████╗\n'
    printf '       ╚═╝      ╚═════╝ ╚══════╝╚═╝ ╚═════╝╚══════╝\n'
    printf '\e[0m'

    printf '\n'

    printf '\e[1;31m'
    printf '       ══════════════════════════════════════════════════════════════\n'
    printf '\e[0m'

    printf '\e[1;97m'
    printf '                         PRINCE Negi, Rahul sir . 2\n'
    printf '\e[0m'

    printf '\e[1;90m'
    printf '                   CYBERSECURITY TRAINING TOOL\n'
    printf '                         BY PRINCE NEGI\n'
    printf '\e[0m'

    printf '\n'
}


# ==============================
# Check Dependencies
# ==============================

dependencies() {

    if ! command -v php >/dev/null 2>&1; then
        echo "[!] PHP is not installed."
        echo "[!] Install PHP and try again."
        exit 1
    fi

    if ! command -v wget >/dev/null 2>&1; then
        echo "[!] wget is not installed."
        echo "[!] Install wget and try again."
        exit 1
    fi
}


# ==============================
# Stop Services
# ==============================

stop() {

    printf "\n"
    printf "[*] Stopping Hound...\n"

    if [[ -n "$CLOUDFLARED_PID" ]]; then
        kill "$CLOUDFLARED_PID" 2>/dev/null
    fi

    if [[ -n "$PHP_PID" ]]; then
        kill "$PHP_PID" 2>/dev/null
    fi

    printf "[+] Services stopped.\n"

    exit 0
}


# ==============================
# Start PHP Server
# ==============================

start_php() {

    local port="$1"

    printf "\e[1;92m"
    printf "[+] Starting PHP server on 127.0.0.1:%s...\n" "$port"
    printf "\e[0m"

    php -S "127.0.0.1:$port" >php.log 2>&1 &
    PHP_PID=$!

    sleep 2

    if ! kill -0 "$PHP_PID" 2>/dev/null; then
        printf "\e[1;31m"
        printf "[!] PHP server failed to start.\n"
        printf "\e[0m"
        exit 1
    fi

    printf "[+] PHP server started. PID: %s\n" "$PHP_PID"
}


# ==============================
# Download Cloudflared
# ==============================

download_cloudflared() {

    if [[ -f "./cloudflared" ]]; then
        printf "[+] Cloudflared already exists.\n"
        return
    fi

    printf "[+] Downloading Cloudflared...\n"

    local arch
    arch=$(uname -m)

    case "$arch" in

        x86_64)
            wget -q \
                https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
                -O cloudflared
            ;;

        aarch64)
            wget -q \
                https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
                -O cloudflared
            ;;

        arm*)
            wget -q \
                https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm \
                -O cloudflared
            ;;

        *)
            printf "\e[1;31m"
            printf "[!] Unsupported architecture: %s\n" "$arch"
            printf "\e[0m"
            exit 1
            ;;

    esac

    chmod +x cloudflared

    printf "[+] Cloudflared ready.\n"
}


# ==============================
# Start Cloudflare Tunnel
# ==============================

start_cloudflare() {

    download_cloudflared

    start_php 3333

    printf "[+] Starting Cloudflare tunnel...\n"

    rm -f cf.log

    ./cloudflared tunnel \
        --url http://127.0.0.1:3333 \
        --logfile cf.log \
        > /dev/null 2>&1 &

    CLOUDFLARED_PID=$!

    sleep 8

    if [[ ! -f cf.log ]]; then
        printf "\e[1;31m"
        printf "[!] Cloudflare log was not created.\n"
        printf "\e[0m"
        stop
    fi

    local link

    link=$(grep -o \
        'https://[-0-9a-zA-Z]*\.trycloudflare.com' \
        cf.log | head -n 1)

    if [[ -z "$link" ]]; then
        printf "\e[1;31m"
        printf "[!] Cloudflare tunnel URL was not generated.\n"
        printf "\e[0m"
        stop
    fi

    printf "\n"

    printf "\e[1;92m"
    printf "[+] Tunnel URL:\n"
    printf "%s\n" "$link"
    printf "\e[0m"

    printf "\n"

    printf "[*] Authorized training server is running.\n"
    printf "[*] Press Ctrl+C to stop.\n"

    wait "$CLOUDFLARED_PID"
}


# ==============================
# Start Local Server
# ==============================

local_server() {

    start_php 8080

    printf "\n"

    printf "\e[1;92m"
    printf "[+] Local server is running.\n"
    printf "[+] http://127.0.0.1:8080\n"
    printf "\e[0m"

    printf "\n"

    printf "[*] Press Ctrl+C to stop.\n"

    wait "$PHP_PID"
}


# ==============================
# Main Function
# ==============================

hound() {

    local option_server="Y"

    printf "\n"

    printf "\e[1;93m"
    printf "Do you want to use Cloudflare Tunnel?\n"
    printf "\e[0m"

    printf "[Y] Cloudflare Tunnel\n"
    printf "[N] Localhost:8080\n"

    read -r -p "[Y/N] [Default: Y]: " option_server

    option_server="${option_server:-Y}"

    case "$option_server" in

        Y|y|Yes|yes)
            start_cloudflare
            ;;

        N|n|No|no)
            local_server
            ;;

        *)
            printf "\e[1;31m"
            printf "[!] Invalid option.\n"
            printf "\e[0m"
            exit 1
            ;;

    esac
}


# ==============================
# Run
# ==============================

banner
dependencies
rishikesh cyber police

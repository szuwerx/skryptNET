#!/bin/bash

# Kolory
NC='\033[0m' # Brak koloru
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'

# Funkcja do wyświetlania publicznego adresu IP
show_public_ip() {
    echo -e "${CYAN}Publiczny adres IP:${NC}"
    curl -s https://api.ipify.org || echo -e "${RED}Nie udało się pobrać publicznego adresu IP!${NC}"
}

# Funkcja do wyświetlania lokalnego adresu IP
show_local_ip() {
    echo -e "${CYAN}Lokalny adres IP:${NC}"
    ip a | grep -oP 'inet \K[\d.]+(?=/)' | head -n 1
}

# Funkcja do wyświetlania adresu MAC routera
show_router_mac() {
    echo -e "${CYAN}Adres MAC routera:${NC}"
    arp -a | grep -m 1 -oP '([a-f0-9]{1,2}[:-]){5}[a-f0-9]{1,2}'
}

# Funkcja do wyświetlania swojego adresu MAC
show_own_mac() {
    echo -e "${CYAN}Twój adres MAC:${NC}"
    ip link show | grep -oP 'link/ether \K([a-f0-9]{2}:){5}[a-f0-9]{2}' | head -n 1
}

# Funkcja do wyświetlania dostępnych adresów IP w sieci lokalnej
show_available_ips() {
    echo -e "${CYAN}Dostępne adresy IP w sieci lokalnej:  ${NC}"
    local ip_subnet=$(ip a | grep -oP 'inet \K[\d.]+(?=/)' | head -n 1 | cut -d '.' -f 1-3)
    for ip in $(seq 1 254); do
        ping -c 1 -w 1 "${ip_subnet}.$ip" &> /dev/null && echo "${GREEN}${ip_subnet}.$ip jest dostępny${NC}"
    done
}

# Funkcja do wyświetlania połączonych urządzeń do routera
show_connected_devices() {
    echo -e "${CYAN}Połączone urządzenia do routera:${NC}"
    arp -a
}

# Funkcja do wyświetlania pełnych informacji o interfejsach sieciowych
show_network_interfaces() {
    echo -e "${CYAN}Informacje o interfejsach sieciowych:${NC}"
    ip a
}

# Funkcja do wyświetlania trasy do routera (traceroute)
show_traceroute() {
    local router_ip=$(ip a | grep -oP 'inet \K[\d.]+(?=/)' | head -n 1 | cut -d '.' -f 1-3).1
    echo -e "${CYAN}Traceroute do routera (${router_ip}):${NC}"
    traceroute -n $router_ip
}

# Funkcja do wyświetlania informacji o połączeniu
show_connection_info() {
    if ! command -v nmcli &>/dev/null; then
        echo -e "${RED}Narzędzie 'nmcli' nie jest zainstalowane!${NC}"
        return 1
    fi
    echo -e "${CYAN}Informacje o połączeniu sieciowym:${NC}"
    nmcli device status
}

# Funkcja do wyświetlania danych o zużyciu sieci
show_network_usage() {
    if ! command -v ifstat &>/dev/null; then
        echo -e "${RED}Narzędzie 'ifstat' nie jest zainstalowane!${NC}"
        return 1
    fi

    local interface=$(ip link | grep -oP '(?<=: ).*?(?=:)' | head -n 1)
    
    ifstat -p "$interface" 1 1 || echo -e "${RED}Błąd podczas pobierania danych o zużyciu sieci!${NC}"
}

# Funkcja do tworzenia animacji kostki 3D
show_3d_cube() {
    clear
    echo -e "${YELLOW}Tworzenie animacji kostki 3D w terminalu!${NC}"
    trap "clear; exit" SIGINT
    while true; do
        echo -e "${CYAN}  ________"
        echo -e "${CYAN} /      /|"
        echo -e "${CYAN}/______/ |"
        echo -e "${CYAN}|      | |"
        echo -e "${CYAN}|      | /"
        echo -e "${CYAN}|______|/"
        sleep 0.5
        clear
        echo -e "${CYAN}   ______"
        echo -e "${CYAN}  /     /|"
        echo -e "${CYAN} /_____/ |"
        echo -e "${CYAN}|      | |"
        echo -e "${CYAN}|      | /"
        echo -e "${CYAN}|______|/"
        sleep 0.5
        clear
    done
}

# Funkcja do sprawdzania dostępności serwisów (pingowanie)
check_service_availability() {
    echo -e "${CYAN}Sprawdzanie dostępności serwisów:${NC}"
    for domain in "google.com" "8.8.8.8" "cloudflare-dns.com"; do
        if ping -c 1 -w 1 "$domain" &>/dev/null; then
            echo -e "${GREEN}Serwis $domain jest dostępny${NC}"
        else
            echo -e "${RED}Serwis $domain jest niedostępny${NC}"
        fi
    done
}

# Funkcja do wyświetlania informacji o systemie
show_system_info() {
    echo -e "${CYAN}Informacje o systemie:${NC}"
    echo -e "${CYAN}CPU:${NC} $(lscpu | grep 'Model name' | sed 's/Model name://')"
    echo -e "${CYAN}RAM:${NC} $(free -h | grep Mem | awk '{print $2}')"
    echo -e "${CYAN}Dysk:${NC} $(df -h | grep '^/dev' | awk '{print $1 " " $2 " " $3 " " $5}')"
}

# Funkcja do tworzenia logów aktywności
log_activity() {
    LOGFILE="network_activity.log"
    echo -e "${CYAN}Logowanie aktywności do pliku ${LOGFILE}:${NC}"
    echo "$(date): Wybrana opcja - $1" >> "$LOGFILE"
}

# Animowane przejście do wyboru opcji
clear
echo -e "${BOLD}${YELLOW}Witaj w skrypcie do zarządzania siecią!${NC}"
echo -e "${CYAN}Wybierz jedną z poniższych opcji:${NC}"

PS3='Wybierz opcję (1-13): '
options=(
    "Pokaż publiczny adres IP"
    "Pokaż lokalny adres IP"
    "Pokaż adres MAC routera"
    "Pokaż swój adres MAC"
    "Pokaż dostępne adresy IP"
    "Pokaż połączone urządzenia do routera"
    "Pokaż pełne informacje o interfejsach sieciowych"
    "Pokaż trasy do routera (traceroute)"
    "Pokaż informacje o połączeniu sieciowym"
    "Pokaż dane o zużyciu sieci"
    "Tworzenie animacji kostki 3D"
    "Sprawdzanie dostępności serwisów (pingowanie)"
    "Informacje o systemie (CPU, RAM, dysk)"
    "Zakończ"
)

select opt in "${options[@]}"
do
    case $opt in
        "Pokaż publiczny adres IP")
            show_public_ip
            log_activity "Pokaż publiczny adres IP"
            ;;
        "Pokaż lokalny adres IP")
            show_local_ip
            log_activity "Pokaż lokalny adres IP"
            ;;
        "Pokaż adres MAC routera")
            show_router_mac
            log_activity "Pokaż adres MAC routera"
            ;;
        "Pokaż swój adres MAC")
            show_own_mac
            log_activity "Pokaż swój adres MAC"
            ;;
        "Pokaż dostępne adresy IP")
            show_available_ips
            log_activity "Pokaż dostępne adresy IP"
            ;;
        "Pokaż połączone urządzenia do routera")
            show_connected_devices
            log_activity "Pokaż połączone urządzenia do routera"
            ;;
        "Pokaż pełne informacje o interfejsach sieciowych")
            show_network_interfaces
            log_activity "Pokaż pełne informacje o interfejsach sieciowych"
            ;;
        "Pokaż trasy do routera (traceroute)")
            show_traceroute
            log_activity "Pokaż trasy do routera (traceroute)"
            ;;
        "Pokaż informacje o połączeniu sieciowym")
            show_connection_info
            log_activity "Pokaż informacje o połączeniu sieciowym"
            ;;
        "Pokaż dane o zużyciu sieci")
            show_network_usage
            log_activity "Pokaż dane o zużyciu sieci"
            ;;
        "Tworzenie animacji kostki 3D")
            show_3d_cube
            log_activity "Tworzenie animacji kostki 3D"
            ;;
        "Sprawdzanie dostępności serwisów (pingowanie)")
            check_service_availability
            log_activity "Sprawdzanie dostępności serwisów"
            ;;
        "Informacje o systemie (CPU, RAM, dysk)")
            show_system_info
            log_activity "Informacje o systemie"
            ;;
        "Zakończ")
            echo -e "${GREEN}Dziękuję za używanie skryptu!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Nieprawidłowy wybór! Proszę wybrać opcję od 1 do 13.${NC}"
            ;;
    esac
done

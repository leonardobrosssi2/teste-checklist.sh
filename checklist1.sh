#!/bin/bash


RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; NC="\e[0m"; BOLD="\e[1m"
MESINFO="${CYAN}${BOLD}[INFO]${NC}"


log_file="${PWD}/checklist.log"
echo -e "${MESINFO} Iniciando checklist do usuário $USER" | tee -a "$log_file"


MALICIOUS_PATTERNS=(
    "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php"
    "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php"
    "configxx.php" "z.php"
)

check_full_scan() {
    echo -e "${MESINFO} Iniciando varredura de malware..." | tee -a "$log_file"
    INFECTED=0
    THRESHOLD=3

    while IFS= read -r file; do
        name=$(basename "$file")
        for p in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$name" == "$p" ]] && ((INFECTED++))
        done
    done < <(find "$PWD" -type f 2>/dev/null)

    if [[ $INFECTED -ge $THRESHOLD ]]; then
        echo -e "${RED}⚠ HOSPEDAGEM INFECTADA (${INFECTED} arquivos suspeitos)${NC}" | tee -a "$log_file"
    else
        echo -e "${GREEN}✓ HOSPEDAGEM LIMPA${NC}" | tee -a "$log_file"
    fi
}


check_cron() {
    echo -e "${YELLOW}\nVERIFICANDO CRONS ATIVAS - Usuário ${CYAN}$USER${NC}" | tee -a "$log_file"
    if [[ -r "/var/spool/cron/$USER" ]]; then
        cat "/var/spool/cron/$USER" | tee -a "$log_file"
    else
        echo -e "${RED}Usuário não possui crons ou sem permissão${NC}" | tee -a "$log_file"
    fi
}


check_lastlogin() {
    echo -e "${YELLOW}\nVERIFICANDO IPS do .lastlogin - Usuário ${CYAN}$USER${NC}" | tee -a "$log_file"
    LASTLOGIN_FILE="/home/$USER/.lastlogin"

    if [[ -r "$LASTLOGIN_FILE" ]]; then
        echo -e "Acesso mais antigo: $(head -n1 "$LASTLOGIN_FILE" | awk '{print $3" "$4}')" | tee -a "$log_file"
        echo -e "Acesso mais recente: $(tail -n1 "$LASTLOGIN_FILE" | awk '{print $3" "$4}')" | tee -a "$log_file"

        if [[ -x /usr/bin/geoiplookup ]]; then
            echo -e "\nOrigem dos IPs:" | tee -a "$log_file"
            for IP in $(awk '{print $1}' "$LASTLOGIN_FILE" | sort | uniq); do
                echo -ne "$IP\t"
                /usr/bin/geoiplookup "$IP" | tee -a "$log_file"
            done
        fi
    else
        echo -e "${RED}Arquivo .lastlogin não existe ou sem permissão${NC}" | tee -a "$log_file"
    fi
}


run_all() {
    check_full_scan
    check_cron
    check_lastlogin
}

case "$1" in
    --all) run_all ;;
    *) echo -e "${YELLOW}Uso: $0 --all${NC}" ; exit 1 ;;
esac

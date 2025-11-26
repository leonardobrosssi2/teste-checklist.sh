#!/bin/bash

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; NC="\e[0m"; BOLD="\e[1m"
MESINFO="${CYAN}${BOLD}[INFO]${NC}"

_chkNotificacoes(){
    echo -ne "${YELLOW}"
    echo -ne "\nVERIFICANDO NOTIFICAÇÕES por TOS ANTERIORES " | tee -a "$log_file"
    echo -ne "- Usuário${CYAN} $USER\n"
    echo -ne "${NC}"
    grep "$USER" /opt/hgmods/monitoring/logs/hgbr_abuse_tos.log | tee -a "$log_file"
    echo -e "${NC}\n"
}

_chkRestricoes(){
    echo -ne "${YELLOW}"
    echo -ne "\nVERIFICANDO RESTRIÇÕES ATIVAS\n" | tee -a "$log_file"
    echo -ne "${NC}"

    if [[ -e /root/bin/montool ]] ; then
        echo -ne "${YELLOW}"
        echo -e "\nRestrictions: " | tee -a "$log_file"
        echo -ne "${NC}"
        /root/bin/montool checkrestrictions "$USER" | tee -a "$log_file"
    fi
    if [[ -e /var/log/abusetool.log ]] ; then
        echo -ne "${YELLOW}"
        echo -e "\nAbusetool: " | tee -a "$log_file"
        echo -ne "${NC}"
        grep "$USER" /var/log/abusetool.log | tee -a "$log_file"
    fi

    echo -ne "${YELLOW}"
    echo -e "\nSuspensão cPanel: " | tee -a "$log_file"
    echo -ne "${NC}"
    /usr/sbin/whmapi1 listsuspended | grep "$USER" | tee -a "$log_file"

    echo -ne "${YELLOW}"
    echo -e "\nOutgoingMail: " | tee -a "$log_file"
    echo -ne "${NC}"
    grep "$USER" /etc/outgoing_mail_suspended_users | tee -a "$log_file"

    for user_domains in $(grep "$USER" /etc/userdomains | awk -F ':' '{print $1}'); do
        grep "$user_domains" /etc/outgoing_mail_suspended_users | tee -a "$log_file"
    done

    echo -e "${NC}\n"
}

_chkCron(){
    echo -ne "${YELLOW}"
    echo -ne "\nVERIFICANDO CRONS ATIVAS " | tee -a "$log_file"
    echo -ne "- Usuário${CYAN} $USER\n"
    echo -ne "${NC}"

    if [[ -e /var/spool/cron/$USER ]] ; then
        cat /var/spool/cron/"$USER" | tee -a "$log_file";
    else
        echo -e "${RED}"
        echo -ne "Usuário não possui crons ativas" | tee -a "$log_file"
        echo -ne "${NC}"
    fi

    echo -e "${NC}\n"
}

_chkLastlogin(){
    echo -ne "${YELLOW}\nVERIFICANDO IPS do .lastlogin - Usuário${CYAN} $USER\n${NC}"

    if [[ -e /home/$USER/.lastlogin ]] ; then
        echo -ne "\nAcesso mais antigo:\t" | tee -a "$log_file"
        head -n1 /home/"$USER"/.lastlogin | awk '{print $3" "$4}' | tee -a "$log_file"

        echo -ne "Acesso mais recente:\t" | tee -a "$log_file"
        tail -n1 /home/"$USER"/.lastlogin | awk '{print $3" "$4}' | tee -a "$log_file"

        echo -e "\nOrigem dos IPs" | tee -a "$log_file"

        if [[ -e /usr/bin/geoiplookup ]] ; then
            for IP in $(awk '{print $1}' /home/"$USER"/.lastlogin | sort | uniq); do
                echo -ne "${BLUE}"
                echo "$IP" | tee -a "$log_file"
                echo -ne "${NC}\t"

                /usr/bin/geoiplookup "$IP" | tee -a "$log_file"

                for DATA in $(grep "$IP" /home/"$USER"/.lastlogin | awk '{print $3"#"$4}'); do
                    echo -ne "\t"
                    date -d"$(sed 's/#/ /' <<< $DATA)" +"%d/%m/%Y - %H:%M:%S"
                done
            done
        fi

        echo -e "\n.lastlogin completo" | tee -a "$log_file"
        cat /home/"$USER"/.lastlogin | tee -a "$log_file"
    else
        echo -e "${RED}"
        echo -ne "Arquivo .lastlogin não existe!" | tee -a "$log_file"
    fi

    echo -e "${NC}\n"
}


MALICIOUS_PATTERNS=(
    "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php"
    "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php"
    "configxx.php" "z.php"
)

check_full_scan() {
    INFECTED=0
    THRESHOLD=3

    while IFS= read -r file; do
        name=$(basename "$file")
        for p in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$name" == "$p" ]] && ((INFECTED++))
        done
    done < <(find "$PWD" -type f 2>/dev/null)

    return $(( INFECTED >= THRESHOLD ? 1 : 0 ))
}

run_all() {
    echo -e "${MESINFO} Iniciando varredura completa do sistema"
    echo -e "${MESINFO} Varredura completa"

    # scanner
    check_full_scan
    FULL=$?

    echo ""
    if [[ $FULL -eq 1 ]]; then
        echo -e "${RED}${BOLD}⚠ HOSPEDAGEM INFECTADA${NC}"
    else
        echo -e "${GREEN}${BOLD}✓ HOSPEDAGEM LIMPA${NC}"
    fi

    # executa suas funções adicionais
    _chkNotificacoes
    _chkRestricoes
    _chkCron
    _chkLastlogin
}

case "$1" in
    --all) run_all ;;
    *) echo -e "${YELLOW}Uso:${NC} $0 --all"; exit 1 ;;
esac

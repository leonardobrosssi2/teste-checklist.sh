#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"
BOLD="\e[1m"

MESINFO="${CYAN}${BOLD}[INFO]${NC}"
MESERRO="${RED}${BOLD}[ERRO]${NC}"

usage() {
    echo -e "${YELLOW}Uso:${NC} $0 --mal | --proc | --all"
    exit 1
}

check_malware() {
    MALICIOUS_PATTERNS=("00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php" "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php" "configxx.php" "z.php")
    echo -e "${MESINFO} Varredura malware:"
    FILES=($(find "$PWD" -type f | head -n 50))
    COUNT=0
    for f in "${FILES[@]}"; do
        for p in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$f" == *"$p" ]] && COUNT=$((COUNT+1))
            [[ $COUNT -ge 3 ]] && echo -e "⚠ INFECTADO" && return
        done
    done
    echo -e "${GREEN}✓ Limpo${NC}"
}

check_processes() {
    echo -e "${MESINFO} Processos que mais consomem CPU/RAM:"
    ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 10
    TOPPID=$(ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | sed -n '2p')
    echo ""
    echo -e "${MESINFO} Processo mais pesado:"
    echo "$TOPPID"
}

ACTION="$1"
[[ -z "$ACTION" ]] && usage

case "$ACTION" in
    --mal) check_malware ;;
    --proc) check_processes ;;
    --all)
        echo -e "${CYAN}${BOLD}==== CHECK MALWARE ====${NC}"
        check_malware
        echo ""
        echo -e "${CYAN}${BOLD}==== CHECK PROCESSOS ====${NC}"
        check_processes
        ;;
    *) usage ;;
esac

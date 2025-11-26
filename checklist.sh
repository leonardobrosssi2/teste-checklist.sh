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
    echo -e "${YELLOW}Uso:${NC} $0 --mal | --proc"
    exit 1
}

check_malware() {
    echo -e "${MESINFO} Iniciando varredura rápida"
    MALICIOUS_PATTERNS=(
        "00.php"
        "11.php"
        "66.php"
        "89.php"
        "vc.php"
        "x1.php"
        "xxx.php"
        "txets.php"
        "sl.php"
        "shell.php"
        "up.php"
        "mailer.php"
        "bypass.php"
        "configxx.php"
        "z.php"
    )

    for pattern in "${MALICIOUS_PATTERNS[@]}"; do
        find "$PWD" -type f -name "$pattern" -print -quit 2>/dev/null | grep -q .
        if [[ $? -eq 0 ]]; then
            echo -e "${RED}${BOLD}INFECÇÃO DETECTADA${NC}"
            return
        fi
    done

    echo -e "${GREEN}${BOLD}Nenhuma infecção detectada${NC}"
}

check_process() {
    echo -e "${MESINFO} Processo consumindo mais recursos"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 5
}

ACTION="$1"

[[ -z "$ACTION" ]] && usage

case "$ACTION" in
    --mal|--malware)
        check_malware
        ;;
    --proc|--process)
        check_process
        ;;
    *)
        usage
        ;;
esac

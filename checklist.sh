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
    echo -e "${YELLOW}Uso:${NC} $0 --mal | --all | --proc"
    exit 1
}

check_malware() {
    MALICIOUS_PATTERNS=(
        "00.php" "11.php" "66.php" "89.php"
        "vc.php" "x1.php" "xxx.php" "txets.php"
        "sl.php" "shell.php" "up.php" "mailer.php"
        "bypass.php" "configxx.php" "z.php"
    )

    INFECTED_COUNT=0
    SCAN_LIMIT=50
    FOUND_THRESHOLD=3

    for file in $(find "$PWD" -maxdepth 1 -type f | head -n $SCAN_LIMIT); do
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            if [[ "$(basename "$file")" == "$pattern" ]]; then
                ((INFECTED_COUNT++))
            fi
        done
        if [[ $INFECTED_COUNT -ge $FOUND_THRESHOLD ]]; then
            echo -e "${RED}${BOLD}⚠ INFECÇÃO DETECTADA.${NC}"
            return
        fi
    done

    echo -e "${GREEN}${BOLD}✓ Nenhum arquivo malicioso encontrado.${NC}"
}

check_all() {
    MALICIOUS_PATTERNS=(
        "00.php" "11.php" "66.php" "89.php"
        "vc.php" "x1.php" "xxx.php" "txets.php"
        "sl.php" "shell.php" "up.php" "mailer.php"
        "bypass.php" "configxx.php" "z.php"
    )

    INFECTED_COUNT=0
    FOUND_THRESHOLD=3

    while IFS= read -r file; do
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            if [[ "$(basename "$file")" == "$pattern" ]]; then
                ((INFECTED_COUNT++))
            fi
        done
        if [[ $INFECTED_COUNT -ge $FOUND_THRESHOLD ]]; then
            echo -e "${RED}${BOLD}⚠ INFECÇÃO DETECTADA (VARREDURA COMPLETA).${NC}"
            return
        fi
    done < <(find "$PWD" -type f)

    echo -e "${GREEN}${BOLD}✓ Nenhum arquivo malicioso encontrado na varredura completa.${NC}"
}

check_process() {
    echo -e "${MESINFO} Processos que mais consomem CPU:"
    ps -eo pid,ppid,user,%cpu,%mem,command --sort=-%cpu | head -n 10
    echo ""
    echo -e "${MESINFO} Processos que mais consomem MEMÓRIA:"
    ps -eo pid,ppid,user,%cpu,%mem,command --sort=-%mem | head -n 10
}

ACTION="$1"

case "$ACTION" in
    --mal)
        check_malware
        ;;
    --all)
        check_all
        ;;
    --proc)
        check_process
        ;;
    *)
        usage
        ;;
esac

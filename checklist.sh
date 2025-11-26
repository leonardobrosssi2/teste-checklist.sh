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
    MALICIOUS_PATTERNS=(
        "00.php" "11.php" "66.php" "89.php" "vc.php"
        "x1.php" "xxx.php" "txets.php" "sl.php"
        "shell.php" "up.php" "mailer.php" "bypass.php"
        "configxx.php" "z.php"
    )

    COUNT=0
    FOUND=0

    echo -e "${MESINFO} Iniciando varredura por arquivos maliciosos"

    ALL_FILES=$(find "$PWD" -type f | head -n 50)

    for file in $ALL_FILES; do
        fname=$(basename "$file")

        for bad in "${MALICIOUS_PATTERNS[@]}"; do
            if [[ "$fname" == "$bad" ]]; then
                ((COUNT++))
                ((FOUND++))
                if [[ $COUNT -ge 3 ]]; then
                    echo -e "⚠ INFECTADO"
                    return 1
                fi
            fi
        done
    done

    if [[ $FOUND -gt 0 ]]; then
        echo -e "⚠ INFECTADO"
    else
        echo -e "✓ LIMPO"
    fi
}

check_proc() {
    echo -e "${MESINFO} Processos que mais consomem CPU e RAM:"
    ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 10

    echo ""
    echo -e "${MESINFO} Processo mais pesado:"
    ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | head -n 2
    echo ""
}

run_all() {
    echo -e "${MESINFO} Iniciando varredura completa"
    check_malware
    echo ""
    check_proc
}

ACTION="$1"

case "$ACTION" in
    --mal) check_malware ;;
    --proc) check_proc ;;
    --all) run_all ;;
    *) usage ;;
esac

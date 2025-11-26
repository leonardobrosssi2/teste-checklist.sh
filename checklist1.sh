#!/bin/bash

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; NC="\e[0m"; BOLD="\e[1m"
MESINFO="${CYAN}${BOLD}[INFO]${NC}"
MESERRO="${RED}${BOLD}[ERRO]${NC}"

MALICIOUS_PATTERNS=(
    "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php"
    "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php"
    "configxx.php" "z.php"
)

check_full_scan() {
    echo -e "${MESINFO} Varredura completa"
    INFECTED=0
    THRESHOLD=3

    while IFS= read -r file; do
        name=$(basename "$file")
        for p in "${MALICIOUS_PATTERNS[@]}"; do
            if [[ "$name" == "$p" ]]; then
                ((INFECTED++))
            fi
        done
        if [[ $INFECTED -ge $THRESHOLD ]]; then
            echo -e "${RED}${BOLD}⚠ INFECTADO${NC}"
            return 1
        fi
    done < <(find "$PWD" -type f)

    echo -e "${GREEN}${BOLD}✓ Sem malwares encontrados${NC}"
    return 0
}

check_process() {
    echo -e "${MESINFO} Processos que mais consomem CPU e RAM"
ps -u $USER -o pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 10
    echo ""
    echo -e "${CYAN}${BOLD}Processo mais pesado${NC}"
    ps -eo pid,%cpu,%mem,cmd --sort=-%mem | head -n 1
    echo ""
}

run_all() {
    echo -e "${MESINFO} Iniciando varredura completa do sistema"

    check_full_scan
    FULL=$?

    echo ""
    check_process

    echo ""
    if [[ $FULL -eq 1 ]]; then
        echo -e "${RED}${BOLD}⚠ SISTEMA INFECTADO${NC}"
    else
        echo -e "${GREEN}${BOLD}✓ SISTEMA LIMPO${NC}"
    fi
}

case "$1" in
    --all) run_all ;;
    *) echo -e "${YELLOW}Uso:${NC} $0 --all"; exit 1 ;;
esac

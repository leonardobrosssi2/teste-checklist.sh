#!/bin/bash

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; NC="\e[0m"; BOLD="\e[1m"
MESINFO="${CYAN}${BOLD}[INFO]${NC}"

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

    check_full_scan
    FULL=$?

    echo ""
    if [[ $FULL -eq 1 ]]; then
        echo -e "${RED}${BOLD}⚠ HOSPEDAGEM INFECTADA${NC}"
    else
        echo -e "${GREEN}${BOLD}✓ HOSPEDAGEM LIMPA${NC}"
    fi
}

case "$1" in
    --all) run_all ;;
    *) echo -e "${YELLOW}Uso:${NC} $0 --all"; exit 1 ;;
esac

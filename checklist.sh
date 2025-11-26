#!/bin/bash

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; NC="\e[0m"; BOLD="\e[1m"
MESINFO="${CYAN}${BOLD}[INFO]${NC}"
MESERRO="${RED}${BOLD}[ERRO]${NC}"

usage() {
    echo -e "${YELLOW}Uso:${NC} $0 --mal | --all | --proc"
    exit 1
}

check_malware() {
    echo -e "${MESINFO} Iniciando varredura rápida${NC}"
    MALICIOUS_PATTERNS=( "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php" "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php" "configxx.php" "z.php" )
    INFECTED=0; FOUND_THRESHOLD=3; SCAN_LIMIT=50; COUNT=0

    for file in $(find "$PWD" -type f | head -n $SCAN_LIMIT); do
        ((COUNT++))
        name=$(basename "$file")
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$name" == "$pattern" ]] && ((INFECTED++))
        done
        [[ $INFECTED -ge $FOUND_THRESHOLD ]] && echo -e "${RED}${BOLD}⚠ INFECTADO${NC}" && return
    done

    echo -e "${GREEN}${BOLD}✓ Sem malwares nos primeiros $SCAN_LIMIT arquivos${NC}"
}

check_malware_all() {
    echo -e "${MESINFO} Iniciando varredura completa${NC}"
    MALICIOUS_PATTERNS=( "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php" "txets.php" "sl.php" "shell.php" "up.php" "mailer.php" "bypass.php" "configxx.php" "z.php" )
    INFECTED=0; FOUND_THRESHOLD=3

    while IFS= read -r file; do
        name=$(basename "$file")
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$name" == "$pattern" ]] && ((INFECTED++))
        done
        [[ $INFECTED -ge $FOUND_THRESHOLD ]] && echo -e "${RED}${BOLD}⚠ INFECTADO${NC}" && return
    done < <(find "$PWD" -type f)

    echo -e "${GREEN}${BOLD}✓ Sem malwares encontrados${NC}"
}

check_process() {
    echo -e "${MESINFO} Processos que mais consomem CPU e RAM:${NC}"
    ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 10
    echo ""
    echo -e "${CYAN}${BOLD}Processo mais pesado:${NC}"
    ps -eo pid,%cpu,%mem,cmd --sort=-%mem | head -n 1
    echo ""
}

ACTION="$1"

case "$ACTION" in
    --mal) check_malware ;;
    --all) check_malware_all ;;
    --proc) check_process ;;
    *) usage ;;
esac

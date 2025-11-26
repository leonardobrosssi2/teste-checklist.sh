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
    echo -e "${YELLOW}Uso:${NC} $0 --all"
    exit 1
}

check_malware() {
    echo -e "${MESINFO} Iniciando varredura rápida${NC}"

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

    FILES_TO_SCAN=$(find "$PWD" -type f 2>/dev/null | head -n 50)

    MATCHES=0

    while read -r file; do
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            [[ "$(basename "$file")" == "$pattern" ]] && ((MATCHES++))
            [[ $MATCHES -ge 3 ]] && {
                echo -e "${RED}${BOLD}⚠ INFECÇÃO DETECTADA${NC}"
                return
            }
        done
    done <<< "$FILES_TO_SCAN"

    echo -e "${GREEN}${BOLD}✓ Nenhum sinal de infecção detectado${NC}"
}

ACTION="$1"

[[ -z "$ACTION" ]] && usage

case "$ACTION" in
    --all)
        check_malware
        ;;
    *)
        usage
        ;;
esac

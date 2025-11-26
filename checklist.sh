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

# ======================
#     MALWARE
# ======================
check_malware() {
    echo -e "${MESINFO} Iniciando varredura de malware"
    MALICIOUS_PATTERNS=(
        "00.php" "11.php" "66.php" "89.php" "vc.php" "x1.php" "xxx.php"
        "txets.php" "sl.php" "shell.php" "up.php" "mailer.php"
        "bypass.php" "configxx.php" "z.php"
    )

    COUNT=0
    MAX_SCAN=50
    FOUND=0

    FILES=$(find "$PWD" -type f | head -n $MAX_SCAN)

    for FILE in $FILES; do
        BASENAME=$(basename "$FILE")
        for pattern in "${MALICIOUS_PATTERNS[@]}"; do
            if [[ "$BASENAME" == "$pattern" ]]; then
                ((FOUND++))
            fi
        done
        ((COUNT++))
        [[ $FOUND -ge 3 ]] && break
    done

    if [[ $FOUND -ge 3 ]]; then
        echo -e "⚠ ${RED}${BOLD}INFECTADO${NC}"
        return 1
    else
        echo -e "✓ ${GREEN}${BOLD}LIMPO${NC}"
        return 0
    fi
}

# ======================
#     PROCESSOS
# ======================
check_processes() {
    echo -e "${MESINFO} Processos que mais consomem CPU e RAM:"
    ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 10

    TOP=$(ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | sed -n '2p')
    echo -e "\n${MESINFO} Processo mais pesado:"
    echo -e "$TOP"
}

# ======================
#     ALL
# ======================
run_all() {
    echo -e "${MESINFO} Iniciando varredura completa"

    USER_HOME=$(eval echo ~$USER)

    echo -e "\n${MESINFO} Varredura em todos os diretórios do usuário:"
    INFECTED_GLOBAL=0

    while IFS= read -r DIR; do
        [[ -d "$DIR" ]] || continue
        cd "$DIR" >/dev/null 2>&1
        RESULT=$(check_malware)
        [[ $? -ne 0 ]] && INFECTED_GLOBAL=1
    done < <(find "$USER_HOME" -maxdepth 4 -type d)

    [[ $INFECTED_GLOBAL -eq 1 ]] && echo -e "⚠ ${RED}${BOLD}INFECTADO${NC}" || echo -e "✓ ${GREEN}${BOLD}LIMPO${NC}"

    echo -e "\n${MESINFO} Analisando Processos:"
    check_processes
}

# ======================
# MAIN
# ======================
ACTION="$1"

[[ -z "$ACTION" ]] && usage

case "$ACTION" in
    --mal)  check_malware ;;
    --proc) check_processes ;;
    --all)  run_all ;;
    *) usage ;;
esac

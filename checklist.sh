#!/bin/bash


# ==========================
#   CORES
# ==========================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"
BOLD="\e[1m"

MESINFO="${CYAN}${BOLD}[INFO]${NC}"
MESERRO="${RED}${BOLD}[ERRO]${NC}"

# ==========================
#   USO
# ==========================
usage() {
    echo -e "${YELLOW}Uso:${NC} $0 --mal"
    echo -e "Exemplo:"
    echo -e "  bash <(curl -sSL \"https://raw.githubusercontent.com/leonardobrosssi2/teste-checklist.sh/main/checklist.sh\") --mal"
    exit 1
}

# ==========================
#   CHECK MALWARE
# ==========================
check_malware() {

    echo ""
    echo -e "${MESINFO} Iniciando varredura por arquivos maliciosos${NC}"
    echo ""

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

    INFECTED=0

    echo -e "${CYAN}${BOLD}► Procurando arquivos suspeitos em:${NC} $PWD"
    echo ""

    for pattern in "${MALICIOUS_PATTERNS[@]}"; do
        RESULTS=$(find "$PWD" -type f -name "$pattern" 2>/dev/null)

        if [[ ! -z "$RESULTS" ]]; then
            INFECTED=1
            echo -e "${MESERRO} Arquivos encontrados correspondendo ao padrão: ${YELLOW}$pattern${NC}"
            echo "$RESULTS"
            echo ""
        fi
    done

    if [[ $INFECTED -eq 1 ]]; then
        echo -e "${RED}${BOLD}⚠ ATENÇÃO: INFECÇÃO DETECTADA.${NC}"
    else
        echo -e "${GREEN}${BOLD}✓ Nenhum arquivo malicioso encontrado.${NC}"
    fi

    echo ""
}

# ==========================
#   MAIN
# ==========================
ACTION="$1"

[[ -z "$ACTION" ]] && usage

case "$ACTION" in
    --mal|--malware)
        check_malware
        ;;
    *)
        usage
        ;;
esac

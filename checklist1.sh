#!/bin/bash

USER_HOME="$HOME"
USER_NAME=$(whoami)

echo "=============================="
echo "INICIANDO CHECKLIST - USUÁRIO: $USER_NAME"
echo "Home: $USER_HOME"
echo "=============================="

echo
echo "[INFO] Checando arquivos do site em $USER_HOME..."
if [ -d "$USER_HOME/loja.cloudlinuxbrasil.com" ]; then
    ls -lah "$USER_HOME/loja.cloudlinuxbrasil.com"
else
    echo "Diretório do site não encontrado."
fi

echo
echo "[INFO] Verificando crons do usuário $USER_NAME..."
if crontab -l -u "$USER_NAME" &>/dev/null; then
    crontab -l -u "$USER_NAME"
else
    echo "Nenhum cron ativo."
fi

echo
echo "[INFO] Verificando últimos logins do usuário $USER_NAME..."
if [ -f "$USER_HOME/.lastlogin" ]; then
    cat "$USER_HOME/.lastlogin"
else
    last -F | grep "$USER_NAME"
fi

echo
echo "[INFO] Verificando IPs de acesso dentro da home..."
if [ -f "$USER_HOME/.ssh/known_hosts" ]; then
    echo "IPs encontrados em .ssh/known_hosts:"
    awk '{print $1}' "$USER_HOME/.ssh/known_hosts" | sort | uniq
else
    echo "Nenhum IP de acesso registrado na home."
fi

echo
echo "[INFO] Verificando permissões e arquivos suspeitos na home..."
find "$USER_HOME" -type f -name "*.php" -o -name "*.js" -o -name "*.html" | while read f; do
    perms=$(stat -c "%A %U %G" "$f")
    echo "$perms  $f"
done

echo
echo "[INFO] Checklist concluído!"

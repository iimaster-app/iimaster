#!/usr/bin/env bash
# oauth-on.sh — включить вход через Яндекс/Google.
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/oauth-on.sh | bash
# Скрипт спросит ClientID и секреты (можно заполнить только один из двух),
# сохранит их в /opt/ii-master/oauth.env (файл виден только владельцу) и перезапустит службу.
# Секреты в команду вставлять НЕ нужно — их спрашивают с терминала.
set -e

ENVFILE=/opt/ii-master/oauth.env
UNIT=/etc/systemd/system/ii-master.service
APP_BASE="https://app.ii-master.ru"

echo '=== Включение входа через Яндекс/Google ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

# 1. Служба должна читать oauth.env
if [ -f "$UNIT" ]; then
  if ! grep -q 'oauth.env' "$UNIT"; then
    sed -i '/^ExecStart=/i EnvironmentFile=-/opt/ii-master/oauth.env' "$UNIT"
    systemctl daemon-reload
    echo 'в службу добавлена строка EnvironmentFile (oauth.env)'
  else
    echo 'служба уже читает oauth.env'
  fi
else
  echo 'ВНИМАНИЕ: нет systemd-службы ii-master — проверьте запуск сервера вручную.'
fi

# 2. Спросим данные с терминала (скрипт пришёл по конвейеру — обычный read получил бы пустоту)
read -r -p 'Яндекс ClientID (или Enter, чтобы пропустить): ' YA_ID < /dev/tty
YA_ID="$(printf '%s' "$YA_ID" | tr -d '[:space:]')"
if [ -n "$YA_ID" ]; then
  read -r -s -p 'Яндекс Client secret: ' YA_SECRET < /dev/tty
  echo ''
  YA_SECRET="$(printf '%s' "$YA_SECRET" | tr -d '[:space:]')"
fi

read -r -p 'Google Client ID (или Enter, чтобы пропустить): ' GO_ID < /dev/tty
GO_ID="$(printf '%s' "$GO_ID" | tr -d '[:space:]')"
if [ -n "$GO_ID" ]; then
  read -r -s -p 'Google Client secret: ' GO_SECRET < /dev/tty
  echo ''
  GO_SECRET="$(printf '%s' "$GO_SECRET" | tr -d '[:space:]')"
fi

if [ -z "$YA_ID" ] && [ -z "$GO_ID" ]; then echo 'Ни один вход не заполнен — отменяю.'; exit 1; fi

# 3. Сохраняем (файл читает только владелец)
umask 077
: > "$ENVFILE"
printf '%s\n' "OAUTH_BASE=$APP_BASE" >> "$ENVFILE"
if [ -n "$YA_ID" ]; then
  printf '%s\n' "YANDEX_CLIENT_ID=$YA_ID" "YANDEX_CLIENT_SECRET=$YA_SECRET" >> "$ENVFILE"
fi
if [ -n "$GO_ID" ]; then
  printf '%s\n' "GOOGLE_CLIENT_ID=$GO_ID" "GOOGLE_CLIENT_SECRET=$GO_SECRET" >> "$ENVFILE"
fi
chmod 600 "$ENVFILE"
echo "данные сохранены в $ENVFILE (секреты скрыты)"

# 4. Перезапуск и проверка
systemctl restart ii-master
sleep 2
echo '=== Какие входы включены ==='
curl -s http://127.0.0.1:8790/api/auth/providers || true
echo ''
echo '=== Адреса возврата (redirect URI) — вставьте их в кабинетах Яндекс и Google ==='
echo "  Яндекс: $APP_BASE/api/auth/yandex/callback"
echo "  Google: $APP_BASE/api/auth/google/callback"
echo 'Готово. После включения на экране входа у кнопок Яндекс/Google исчезнет пометка «скоро».'

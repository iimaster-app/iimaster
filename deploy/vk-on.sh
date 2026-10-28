#!/usr/bin/env bash
# vk-on.sh — включить вход через VK ID (id.vk.com).
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/vk-on.sh | bash
# Скрипт спросит ID приложения и защищённый ключ, сохранит их в /opt/ii-master/oauth.env
# (строки Яндекса и Google в этом файле не трогаются) и перезапустит службу.
# Секреты в команду вставлять не нужно — их спрашивают с терминала, на экране не видно.
set -e

ENVFILE=/opt/ii-master/oauth.env
UNIT=/etc/systemd/system/ii-master.service
APP_BASE="https://app.ii-master.ru"

echo '=== Включение входа через VK ID ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

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

echo ''
echo 'Адрес возврата, который должен быть указан в приложении VK ID:'
echo "  $APP_BASE/api/auth/vk/callback"
echo ''
read -r -p 'ID приложения VK (цифры) или Enter, чтобы отменить: ' VKID < /dev/tty
VKID="$(printf '%s' "$VKID" | tr -d '[:space:]')"
if [ -z "$VKID" ]; then echo 'Пусто — отменяю.'; exit 1; fi
case "$VKID" in *[!0-9]*) echo 'ID приложения должен состоять только из цифр.'; exit 1;; esac

read -r -s -p 'Защищённый ключ VK (на экране не видно): ' VKSECRET < /dev/tty
echo ''
VKSECRET="$(printf '%s' "$VKSECRET" | tr -d '[:space:]')"
if [ -z "$VKSECRET" ]; then echo 'Ключ пуст — отменяю.'; exit 1; fi

# Старые строки VK убираем, остальные (Яндекс, Google, OAUTH_BASE) сохраняем как есть.
umask 077
TMP="$(mktemp)"
if [ -f "$ENVFILE" ]; then
  grep -v -E '^(VK_CLIENT_ID|VK_CLIENT_SECRET)=' "$ENVFILE" > "$TMP" || true
fi
if ! grep -q '^OAUTH_BASE=' "$TMP" 2>/dev/null; then
  printf '%s\n' "OAUTH_BASE=$APP_BASE" >> "$TMP"
fi
printf '%s\n' "VK_CLIENT_ID=$VKID" "VK_CLIENT_SECRET=$VKSECRET" >> "$TMP"
mv "$TMP" "$ENVFILE"
chmod 600 "$ENVFILE"
echo "сохранено в $ENVFILE (ID=$VKID, ключ скрыт)"

systemctl restart ii-master
sleep 3
echo '=== Проверка ==='
curl -s http://127.0.0.1:8790/api/auth/providers || true
echo ''
echo 'Должно быть: {"yandex":...,"google":...,"vk":true}'
echo 'Если vk:true — кнопка «VK ID» на экране входа станет рабочей.'

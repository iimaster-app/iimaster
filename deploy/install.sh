#!/usr/bin/env bash
# Установка облачного сервера «ИИ Мастер» (пилот). Ubuntu 24.04, запуск от root.
# Скрипт короткий, чтобы вставлять в веб-консоль одной строкой:
#   curl -fsSL https://iimaster-app.github.io/iimaster/deploy/install.sh | bash
set -e
echo '=== 1/5 Обновляю списки пакетов'
apt-get update -qq
echo '=== 2/5 Ставлю curl, unzip, Caddy'
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl unzip caddy ca-certificates
echo '=== 3/5 Ставлю Node 22 (нужен для встроенной базы; системный Node 18 не подходит)'
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs
echo '=== 4/5 Скачиваю и распаковываю приложение'
mkdir -p /opt/ii-master
cd /opt/ii-master
curl -fsSL -o app.zip https://iimaster-app.github.io/iimaster/deploy/ii-master-cloud.zip
unzip -oq app.zip
echo '=== 5/5 Автозапуск службы и HTTPS'
printf '%s\n' 'app.ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' > /etc/caddy/Caddyfile
systemctl restart caddy
printf '%s\n' '[Unit]' 'Description=II Master cloud' 'After=network.target' '' '[Service]' 'WorkingDirectory=/opt/ii-master' 'Environment=CLOUD_PORT=8790' 'Environment=CLOUD_DATA=/opt/ii-master/data' 'ExecStart=/usr/bin/node --no-warnings tools/cloud/server.js' 'Restart=always' 'RestartSec=5' '' '[Install]' 'WantedBy=multi-user.target' > /etc/systemd/system/ii-master.service
systemctl daemon-reload
systemctl enable --now ii-master
sleep 3
echo '=== Проверка:'
curl -s http://127.0.0.1:8790/api/health || echo 'Сервер не ответил — сообщите этот текст помощнику.'
echo ''
echo '=== Если выше было {"ok":true,...} — установка прошла успешно.'

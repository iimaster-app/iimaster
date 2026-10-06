#!/usr/bin/env bash
# fix.sh — короткая команда: восстановить/обновить облачное приложение и лендинг.
# Запуск в веб-консоли сервера:  cd / && curl -fsSL <url>/fix.sh | bash
set -e
cd /
ZIP="https://raw.githubusercontent.com/iimaster-app/iimaster/main/deploy/ii-master-cloud-v36.zip"
RAW="https://raw.githubusercontent.com/iimaster-app/iimaster/main"
echo '=== 1/4 Скачиваю архив приложения ==='
curl -fsSL -o /tmp/app.zip "$ZIP"
echo '=== 2/4 Распаковываю в /opt/ii-master/app ==='
rm -rf /opt/ii-master/app
mkdir -p /opt/ii-master/app
cd /opt/ii-master/app
unzip -oq /tmp/app.zip
ls tools/cloud/server.js >/dev/null
ls site/index.html >/dev/null
ls src/index.html >/dev/null
echo '=== 3/4 Файлы сайта (значок и Яндекс) ==='
curl -fsSL -o favicon.ico "$RAW/favicon.ico" || true
curl -fsSL -o yandex_3f67930bc96e723a.html "$RAW/yandex_3f67930bc96e723a.html" || true
echo '=== 4/4 Перезапускаю службу ==='
systemctl restart ii-master || true
sleep 2
curl -s http://127.0.0.1:8790/api/health
echo ''
echo 'Готово. Откройте https://ii-master.ru/ и https://app.ii-master.ru/'

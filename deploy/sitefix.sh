#!/usr/bin/env bash
# sitefix.sh — кладёт в корень сайта ii-master.ru два файла:
#   1) favicon.ico — значок сайта (робот) для выдачи Яндекса и вкладки браузера;
#   2) yandex_<хэш>.html — файл подтверждения прав в Яндекс.Вебмастере.
#
# Зачем: домен ii-master.ru обслуживает этот же сервер (облако «ИИ Мастер»),
# он отдаёт файлы прямо из папки /opt/ii-master/app. Кладём их туда.
#
# Запуск в веб-консоли сервера (короткая команда, без подчёркиваний):
#   curl -fsSL https://raw.githubusercontent.com/iimaster-app/iimaster/main/deploy/sitefix.sh | bash
set -e
DIR=/opt/ii-master/app
BASE=https://raw.githubusercontent.com/iimaster-app/iimaster/main

cd "$DIR"
echo 'Скачиваю значок сайта и файлы подтверждения Яндекса...'
curl -fsSL -o favicon.ico "$BASE/favicon.ico"
# основной код подтверждения (Яндекс.Вебмастер .ru)
curl -fsSL -o yandex_3f67930bc96e723a.html "$BASE/yandex_3f67930bc96e723a.html"
# старый код (казахское зеркало .kz) — оставляем на всякий случай, не критично
curl -fsSL -o yandex_f625d3331d59a3a2.html "$BASE/yandex_f625d3331d59a3a2.html" || true

echo ''
echo 'Готово. Файлы на месте:'
ls -l favicon.ico yandex_3f67930bc96e723a.html yandex_f625d3331d59a3a2.html
echo ''
echo 'Проверьте в браузере:'
echo '  https://ii-master.ru/yandex_3f67930bc96e723a.html   (должно быть: Verification: 3f67930bc96e723a)'
echo '  https://ii-master.ru/favicon.ico'

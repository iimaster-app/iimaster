#!/usr/bin/env bash
# model-on.sh — включить ОБЩИЙ КЛЮЧ: приложение отвечает нашей моделью, пользователям ключи не нужны.
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/model-on.sh | bash
# Скрипт спросит ключ сервиса (z.ai), сохранит его в /opt/ii-master/model.env,
# пропишет переменные в службу и перезапустит её. Ключ в команду вставлять не нужно -
# он останется на сервере и в приложение не попадёт. Файл читает только владелец (chmod 600).
set -e

ENVFILE=/opt/ii-master/model.env
UNIT=/etc/systemd/system/ii-master.service

echo '=== Включение общего доступа (наш ключ на сервере) ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

# 1. Служба должна читать model.env (добавим строку, если её ещё нет)
if [ -f "$UNIT" ]; then
  if ! grep -q 'model.env' "$UNIT"; then
    sed -i '/^ExecStart=/i EnvironmentFile=-/opt/ii-master/model.env' "$UNIT"
    systemctl daemon-reload
    echo 'в службу добавлена строка EnvironmentFile (model.env)'
  else
    echo 'служба уже читает model.env'
  fi
else
  echo 'ВНИМАНИЕ: нет systemd-службы ii-master — проверьте запуск сервера вручную.'
fi

# 2. Ключ сервиса (z.ai). Читаем с терминала: скрипт пришёл по конвейеру, обычный read получил бы пустоту.
read -r -s -p 'Вставьте ключ z.ai и нажмите Enter (на экране не показывается): ' KEY < /dev/tty
echo ''
KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
if [ -z "$KEY" ]; then echo 'Пусто — отменяю.'; exit 1; fi

# 3. Модели и цена ответа (можно поменять позже, отредактировав файл)
MODEL="${CLOUD_MODEL:-glm-4.5-flash}"          # бесплатная модель - отвечает при нулевом балансе
VISION="${CLOUD_MODEL_VISION:-glm-4.6v-flash}" # разбор картинок (тоже бесплатная)
RUB="${CLOUD_ASSIST_RUB:-1.5}"                 # сколько рублей списывать за один ответ

umask 077
printf '%s\n' \
  "CLOUD_MODEL_KEY=$KEY" \
  "OWNER_ZAI_KEY=$KEY" \
  "CLOUD_MODEL=$MODEL" \
  "CLOUD_MODEL_VISION=$VISION" \
  "CLOUD_MODEL_BASE=${CLOUD_MODEL_BASE:-https://api.z.ai/api/paas/v4}" \
  "CLOUD_ASSIST_RUB=$RUB" > "$ENVFILE"
chmod 600 "$ENVFILE"
echo "сохранено в $ENVFILE (ключ скрыт; модель=$MODEL, за ответ $RUB ₽)"

# 4. Перезапуск и проверка: сервер должен сказать, что общий доступ включён
systemctl restart ii-master
sleep 3
echo '=== Проверка сервера ==='
curl -s http://127.0.0.1:8790/api/health || true
echo ''
echo '=== Состояние общего доступа ==='
curl -s http://127.0.0.1:8790/api/assistant || true
echo ''
echo '=== Готово ==='
echo 'Если в ответе "on":true — общий доступ работает: пользователям ключи вводить не нужно,'
echo 'Баксы списываются за каждый ответ. Изменить модель или цену: отредактируйте'
echo "$ENVFILE и выполните: systemctl restart ii-master"

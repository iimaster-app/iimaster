#!/usr/bin/env bash
# keys-on.sh — вставить ключи сервисов ОДНИМ разом. Ключи вводятся на сервере (в командной строке
# их не видно), файл читает только root. В чат и в историю ничего не попадает.
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/keys-on.sh | bash
# Enter на любом шаге = пропустить (старое значение остаётся).
set -e

ENVFILE=/opt/ii-master/model.env
UNIT=/etc/systemd/system/ii-master.service

echo '=== Ключи ИИ Мастер (вводятся только на сервере) ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

# 1. Служба должна читать model.env
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

# 2. Текущие значения (если файл уже есть)
CUR_KEY=''; CUR_MODEL='glm-4.5-flash'; CUR_VISION='glm-4.6v-flash'; CUR_RUB='1.5'; CUR_LIMIT='100'
if [ -f "$ENVFILE" ]; then
  CUR_KEY="$((grep -E '^CLOUD_MODEL_KEY=' "$ENVFILE" || true) | cut -d= -f2-)"
  CUR_MODEL="$((grep -E '^CLOUD_MODEL=' "$ENVFILE" || true) | cut -d= -f2-)"
  CUR_VISION="$((grep -E '^CLOUD_MODEL_VISION=' "$ENVFILE" || true) | cut -d= -f2-)"
  CUR_RUB="$((grep -E '^CLOUD_ASSIST_RUB=' "$ENVFILE" || true) | cut -d= -f2-)"
fi
[ -n "$CUR_MODEL" ] || CUR_MODEL='glm-4.5-flash'
[ -n "$CUR_VISION" ] || CUR_VISION='glm-4.6v-flash'
[ -n "$CUR_RUB" ] || CUR_RUB='1.5'

echo ''
echo 'Шаг 1. Ключ z.ai (текст и разбор картинок — общий доступ).'
if [ -n "$CUR_KEY" ]; then
  echo "  сейчас ключ уже задан (…${CUR_KEY: -4}). Enter — оставить его."
else
  echo '  сейчас ключ не задан.'
fi
read -r -s -p '  Ключ z.ai (Enter — оставить/пропустить): ' KEY < /dev/tty
echo ''
KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
[ -n "$KEY" ] || KEY="$CUR_KEY"

echo ''
echo 'Шаг 2. Модели (Enter — как сейчас).'
read -r -p "  Модель для ответов [$CUR_MODEL]: " MODEL < /dev/tty
[ -n "$MODEL" ] || MODEL="$CUR_MODEL"
read -r -p "  Модель для картинок/зрения [$CUR_VISION]: " VISION < /dev/tty
[ -n "$VISION" ] || VISION="$CUR_VISION"

echo ''
echo 'Шаг 3. Цена ответа и дневной лимит (Enter — как сейчас).'
read -r -p "  Рублей за ответ [$CUR_RUB]: " RUB < /dev/tty
[ -n "$RUB" ] || RUB="$CUR_RUB"
read -r -p "  Дневной лимит на пользователя, ₽ [$CUR_LIMIT]: " LIMIT < /dev/tty
[ -n "$LIMIT" ] || LIMIT="$CUR_LIMIT"

if [ -z "$KEY" ]; then
  echo 'Ключ z.ai не задан — общий доступ работать не будет. Отменяю.'
  exit 1
fi

umask 077
printf '%s\n' \
  "CLOUD_MODEL_KEY=$KEY" \
  "CLOUD_MODEL=$MODEL" \
  "CLOUD_MODEL_VISION=$VISION" \
  "CLOUD_MODEL_BASE=${CLOUD_MODEL_BASE:-https://api.z.ai/api/paas/v4}" \
  "CLOUD_ASSIST_RUB=$RUB" > "$ENVFILE"
chmod 600 "$ENVFILE"
printf '%s\n' "CLOUD_LIMIT_RUB=$LIMIT" > /opt/ii-master/limit.env
chmod 600 /opt/ii-master/limit.env
echo ''
echo "сохранено: $ENVFILE и /opt/ii-master/limit.env (ключ скрыт, читает только root)"

systemctl restart ii-master
sleep 3
echo '=== Проверка ==='
curl -s http://127.0.0.1:8790/api/health || true
echo ''
curl -s http://127.0.0.1:8790/api/assistant || true
echo ''
echo 'Если "on":true — всё работает: пользователям ключи не нужны.'

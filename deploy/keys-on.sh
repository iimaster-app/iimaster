#!/usr/bin/env bash
# keys-on.sh — вставить ключи сервисов ОДНИМ разом. Ключи вводятся на сервере (в командной строке
# их не видно), файл читает только root. В чат и в переписку ничего не попадает.
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/keys-on.sh | bash
# Enter на любом шаге = оставить текущее значение.
set -e

ENVFILE=/opt/ii-master/model.env
LIMFILE=/opt/ii-master/limit.env
UNIT=/etc/systemd/system/ii-master.service

echo '=== Ключи ИИ Мастер (вводятся только на сервере) ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

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

CUR_KEY=''
CUR_GPT=''
CUR_YA=''
CUR_YAF=''
CUR_MODEL='glm-4.5-flash'
CUR_VISION='glm-4.6v-flash'
CUR_RUB='1.5'
CUR_SMART='3'
CUR_LIMIT='100'
if [ -f "$ENVFILE" ]; then
  CUR_KEY="$(grep -E '^CLOUD_MODEL_KEY=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_GPT="$(grep -E '^CLOUD_GPT_KEY=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_YA="$(grep -E '^CLOUD_YANDEX_TTS_KEY=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_YAF="$(grep -E '^CLOUD_YANDEX_FOLDER=' "$ENVFILE" | cut -d= -f2- || true)"
  # OWNER_ZAI_KEY — ключ для пути через /proxy (его пишет model-on.sh). Сохраняем: файл перезаписывается целиком.
  CUR_OWNER="$(grep -E '^OWNER_ZAI_KEY=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_MODEL="$(grep -E '^CLOUD_MODEL=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_VISION="$(grep -E '^CLOUD_MODEL_VISION=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_RUB="$(grep -E '^CLOUD_ASSIST_RUB=' "$ENVFILE" | cut -d= -f2- || true)"
  CUR_SMART="$(grep -E '^CLOUD_SMART_RUB=' "$ENVFILE" | cut -d= -f2- || true)"
fi
[ -n "$CUR_MODEL" ] || CUR_MODEL='glm-4.5-flash'
[ -n "$CUR_VISION" ] || CUR_VISION='glm-4.6v-flash'
[ -n "$CUR_RUB" ] || CUR_RUB='1.5'
[ -n "$CUR_SMART" ] || CUR_SMART='3'
if [ -f "$LIMFILE" ]; then
  CUR_LIMIT="$(grep -E '^CLOUD_LIMIT_RUB=' "$LIMFILE" | cut -d= -f2- || true)"
fi
[ -n "$CUR_LIMIT" ] || CUR_LIMIT='100'

echo ''
echo 'Шаг 1. Ключ z.ai — текстовые ответы и разбор картинок.'
if [ -n "$CUR_KEY" ]; then echo "  сейчас задан (…${CUR_KEY: -4}). Enter — оставить."; else echo '  сейчас не задан.'; fi
read -r -s -p '  Ключ z.ai (Enter — оставить): ' KEY < /dev/tty
echo ''
KEY="$(printf '%s' "$KEY" | tr -d '[:space:]')"
[ -n "$KEY" ] || KEY="$CUR_KEY"

echo ''
echo 'Шаг 2. Ключ GPTunnel — картинки, видео, музыка и умный режим для всех.'
if [ -n "$CUR_GPT" ]; then echo "  сейчас задан (…${CUR_GPT: -4}). Enter — оставить."; else echo '  сейчас не задан.'; fi
read -r -s -p '  Ключ GPTunnel (Enter — оставить): ' GPTKEY < /dev/tty
echo ''
GPTKEY="$(printf '%s' "$GPTKEY" | tr -d '[:space:]')"
[ -n "$GPTKEY" ] || GPTKEY="$CUR_GPT"

echo ''
echo 'Шаг 3. Ключ Yandex SpeechKit — озвучка (диктор) для всех.'
if [ -n "$CUR_YA" ]; then echo "  сейчас задан (…${CUR_YA: -4}). Enter — оставить."; else echo '  сейчас не задан.'; fi
read -r -s -p '  API-ключ Yandex (Enter — оставить): ' YAKEY < /dev/tty
echo ''
YAKEY="$(printf '%s' "$YAKEY" | tr -d '[:space:]')"
[ -n "$YAKEY" ] || YAKEY="$CUR_YA"
read -r -p "  Каталог Yandex (folder id) [$CUR_YAF]: " YAF < /dev/tty
[ -n "$YAF" ] || YAF="$CUR_YAF"

echo ''
echo 'Шаг 4. Модели (Enter — как сейчас).'
read -r -p "  Модель для ответов [$CUR_MODEL]: " MODEL < /dev/tty
[ -n "$MODEL" ] || MODEL="$CUR_MODEL"
read -r -p "  Модель для картинок/зрения [$CUR_VISION]: " VISION < /dev/tty
[ -n "$VISION" ] || VISION="$CUR_VISION"

echo ''
echo 'Шаг 5. Цены и лимит (Enter — как сейчас).'
read -r -p "  Рублей за ответ [$CUR_RUB]: " RUB < /dev/tty
[ -n "$RUB" ] || RUB="$CUR_RUB"
read -r -p "  Рублей за «умный» ответ [$CUR_SMART]: " SMART < /dev/tty
[ -n "$SMART" ] || SMART="$CUR_SMART"
read -r -p "  Дневной лимит на пользователя, ₽ [$CUR_LIMIT]: " LIMIT < /dev/tty
[ -n "$LIMIT" ] || LIMIT="$CUR_LIMIT"

if [ -z "$KEY" ]; then
  echo 'Ключ z.ai пуст — текстовые ответы работать не будут. Отменяю.'
  exit 1
fi

umask 077
{
  printf '%s\n' "CLOUD_MODEL_KEY=$KEY"
  if [ -n "$CUR_OWNER" ]; then printf '%s\n' "OWNER_ZAI_KEY=$CUR_OWNER"; fi
  if [ -n "$GPTKEY" ]; then printf '%s\n' "CLOUD_GPT_KEY=$GPTKEY"; fi
  if [ -n "$YAKEY" ]; then
    printf '%s\n' "CLOUD_YANDEX_TTS_KEY=$YAKEY"
    printf '%s\n' "CLOUD_YANDEX_FOLDER=$YAF"
  fi
  printf '%s\n' \
    "CLOUD_MODEL=$MODEL" \
    "CLOUD_MODEL_VISION=$VISION" \
    "CLOUD_MODEL_BASE=${CLOUD_MODEL_BASE:-https://api.z.ai/api/paas/v4}" \
    "CLOUD_ASSIST_RUB=$RUB" \
    "CLOUD_SMART_RUB=$SMART"
} > "$ENVFILE"
chmod 600 "$ENVFILE"
printf '%s\n' "CLOUD_LIMIT_RUB=$LIMIT" > "$LIMFILE"
chmod 600 "$LIMFILE"
echo ''
echo "сохранено: $ENVFILE и $LIMFILE (ключи скрыты, читает только root)"

systemctl restart ii-master
sleep 3
echo '=== Проверка ==='
curl -s http://127.0.0.1:8790/api/health || true
echo ''
curl -s http://127.0.0.1:8790/api/assistant || true
echo ''
echo 'Должно быть: "on":true, "gpt":true, "tts":true — значит текст, картинки/видео/музыка и озвучка'
echo 'работают нашими ключами, и пользователям ничего вводить не нужно.'

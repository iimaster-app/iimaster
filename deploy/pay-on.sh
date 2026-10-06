#!/usr/bin/env bash
# pay-on.sh — включить боевой приём оплат через ЮKassa.
# Запуск в веб-консоли сервера (от root):
#   cd / && curl -fsSL <url>/pay-on.sh | bash
# Скрипт спросит shopId и секретный ключ, сохранит их в /opt/ii-master/pay.env
# и перезапустит службу. Секреты в команду вставлять не нужно.
set -e

ENVFILE=/opt/ii-master/pay.env
UNIT=/etc/systemd/system/ii-master.service

echo '=== Включение оплаты ЮKassa ==='
[ "$(id -u)" = "0" ] || { echo 'Нужно запускать от root (в веб-консоли вы и так root).'; exit 1; }
[ -d /opt/ii-master/app ] || { echo 'Нет /opt/ii-master/app — сначала обновите облако (fix.sh).'; exit 1; }

# 1. Убедимся, что служба читает pay.env (добавим строку, если её ещё нет)
if [ -f "$UNIT" ]; then
  if ! grep -q 'pay.env' "$UNIT"; then
    sed -i '/^ExecStart=/i EnvironmentFile=-/opt/ii-master/pay.env' "$UNIT"
    systemctl daemon-reload
    echo 'в службу добавлена строка EnvironmentFile (pay.env)'
  else
    echo 'служба уже читает pay.env'
  fi
else
  echo 'ВНИМАНИЕ: нет systemd-службы ii-master — проверьте запуск сервера вручную.'
fi

# 2. Спросим данные. Читаем с терминала: скрипт пришёл по конвейеру, обычный read получил бы пустоту.
read -r -p 'Вставьте shopId (только цифры) и нажмите Enter: ' SHOP < /dev/tty
read -r -s -p 'Вставьте секретный ключ (live_... или test_...) и нажмите Enter: ' SECRET < /dev/tty
echo ''
SHOP="$(printf '%s' "$SHOP" | tr -d '[:space:]')"
SECRET="$(printf '%s' "$SECRET" | tr -d '[:space:]')"
if [ -z "$SHOP" ] || [ -z "$SECRET" ]; then echo 'Пусто — отменяю.'; exit 1; fi
case "$SHOP" in *[!0-9]*) echo 'shopId должен состоять только из цифр.'; exit 1;; esac

# 3. Сохраним (файл читает только владелец)
umask 077
printf '%s\n' "YOOKASSA_SHOP_ID=$SHOP" "YOOKASSA_SECRET_KEY=$SECRET" > "$ENVFILE"
chmod 600 "$ENVFILE"
echo "данные сохранены в $ENVFILE (shopId=$SHOP, ключ скрыт)"

# 4. Перезапуск и проверка
systemctl restart ii-master
sleep 2
echo '=== Проверка сервера ==='
curl -s http://127.0.0.1:8790/api/health || true
echo ''
echo '=== Готово ==='
echo 'Не забудьте в кабинете ЮKassa указать вебхук: https://ii-master.ru/api/pay/yookassa/result'
echo 'Событие: payment.succeeded. После этого сделайте тестовую покупку.'

#!/usr/bin/env bash
# Р Р€РЎРѓРЎвЂљР В°Р Р…Р С•Р Р†Р С”Р В° Р С•Р В±Р В»Р В°РЎвЂЎР Р…Р С•Р С–Р С• РЎРѓР ВµРЎР‚Р Р†Р ВµРЎР‚Р В° Р’В«Р ВР В Р СљР В°РЎРѓРЎвЂљР ВµРЎР‚Р’В» (Р С—Р С‘Р В»Р С•РЎвЂљ). Ubuntu 24.04, Р В·Р В°Р С—РЎС“РЎРѓР С” Р С•РЎвЂљ root.
# Р С™Р С•РЎР‚Р С•РЎвЂљР С”Р В°РЎРЏ Р С”Р С•Р СР В°Р Р…Р Т‘Р В° Р Т‘Р В»РЎРЏ Р Р†Р ВµР В±-Р С”Р С•Р Р…РЎРѓР С•Р В»Р С‘ (Р СР С•Р В¶Р Р…Р С• Р В·Р В°Р С—РЎС“РЎРѓР С”Р В°РЎвЂљРЎРЉ Р С—Р С•Р Р†РЎвЂљР С•РЎР‚Р Р…Р С• РІР‚вЂќ Р С•Р Р…Р В° РЎРѓР В°Р СР В° Р Р†РЎРѓРЎвЂ Р С—Р С•РЎвЂЎР С‘Р Р…Р С‘РЎвЂљ):
#   curl -fsSL https://iimaster-app.github.io/iimaster/deploy/install.sh | bash
# Р СџРЎР‚Р С‘Р В»Р С•Р В¶Р ВµР Р…Р С‘Р Вµ РЎРѓРЎвЂљР В°Р Р†Р С‘РЎвЂљРЎРѓРЎРЏ Р Р† /opt/ii-master/app, Р Т‘Р В°Р Р…Р Р…РЎвЂ№Р Вµ (Р В±Р В°Р В·Р В°) Р В¶Р С‘Р Р†РЎС“РЎвЂљ Р С•РЎвЂљР Т‘Р ВµР В»РЎРЉР Р…Р С• Р Р† /opt/ii-master/data.
set -e
cd /
echo '=== 1/5 Р С›Р В±Р Р…Р С•Р Р†Р В»РЎРЏРЎР‹ РЎРѓР С—Р С‘РЎРѓР С”Р С‘ Р С—Р В°Р С”Р ВµРЎвЂљР С•Р Р†'
apt-get update -qq
echo '=== 2/5 Р РЋРЎвЂљР В°Р Р†Р В»РЎР‹ curl, unzip, Caddy'
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl unzip caddy ca-certificates
echo '=== 3/5 Р РЋРЎвЂљР В°Р Р†Р В»РЎР‹ Node 22 (Р Р…РЎС“Р В¶Р ВµР Р… Р Т‘Р В»РЎРЏ Р Р†РЎРѓРЎвЂљРЎР‚Р С•Р ВµР Р…Р Р…Р С•Р в„– Р В±Р В°Р В·РЎвЂ№; РЎРѓР С‘РЎРѓРЎвЂљР ВµР СР Р…РЎвЂ№Р в„– Node 18 Р Р…Р Вµ Р С—Р С•Р Т‘РЎвЂ¦Р С•Р Т‘Р С‘РЎвЂљ)'
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs
echo '=== 4/5 Р РЋР С”Р В°РЎвЂЎР С‘Р Р†Р В°РЎР‹ Р С‘ РЎР‚Р В°РЎРѓР С—Р В°Р С”Р С•Р Р†РЎвЂ№Р Р†Р В°РЎР‹ Р С—РЎР‚Р С‘Р В»Р С•Р В¶Р ВµР Р…Р С‘Р Вµ'
curl -fsSL -o app.zip "https://raw.githubusercontent.com/iimaster-app/iimaster/main/deploy/ii-master-cloud-v34.zip"
rm -rf /opt/ii-master/app
mkdir -p /opt/ii-master/app
cd /opt/ii-master/app
# ?v= РІР‚вЂќ Р В·Р В°РЎвЂ°Р С‘РЎвЂљР В° Р С•РЎвЂљ Р С”РЎРЊРЎв‚¬Р В°: Р В±Р ВµР В· Р Р…Р ВµР С–Р С• GitHub Р СР С•Р В¶Р ВµРЎвЂљ Р С•РЎвЂљР Т‘Р В°РЎвЂљРЎРЉ РЎРѓРЎвЂљР В°РЎР‚РЎС“РЎР‹ Р С”Р С•Р С—Р С‘РЎР‹ Р В°РЎР‚РЎвЂ¦Р С‘Р Р†Р В°
# Р¤Р°Р№Р» Р±РµСЂС‘Рј РЅР°РїСЂСЏРјСѓСЋ РёР· СЂРµРїРѕР·РёС‚РѕСЂРёСЏ: РїР°РїРєР° deploy РЅР° GitHub Pages РѕС‚РґР°С‘С‚ 404
# (Р±РѕР»СЊС€РёРµ zip РЅРµ РїСЂРѕС…РѕРґСЏС‚ СЃР±РѕСЂРєСѓ СЃС‚СЂР°РЅРёС†), Р° РїСЂСЏРјР°СЏ СЃСЃС‹Р»РєР° СЂР°Р±РѕС‚Р°РµС‚ РІСЃРµРіРґР°.

unzip -oq ../app.zip
# site files for Yandex (favicon + verification) - keep them after every update
curl -fsSL -o favicon.ico "https://raw.githubusercontent.com/iimaster-app/iimaster/main/favicon.ico" || true
curl -fsSL -o yandex_3f67930bc96e723a.html "https://raw.githubusercontent.com/iimaster-app/iimaster/main/yandex_3f67930bc96e723a.html" || true
grep -q 'api/backup/with-account' tools/cloud/server.js || { echo 'Р С›Р РЃР ВР вЂР С™Р С’: Р Р† Р В°РЎР‚РЎвЂ¦Р С‘Р Р†Р Вµ РЎРѓРЎвЂљР В°РЎР‚РЎвЂ№Р в„– Р С”Р С•Р Т‘ РЎРѓР ВµРЎР‚Р Р†Р ВµРЎР‚Р В° РІР‚вЂќ РЎРѓР С•Р С•Р В±РЎвЂ°Р С‘РЎвЂљР Вµ Р С—Р С•Р СР С•РЎвЂ°Р Р…Р С‘Р С”РЎС“'; exit 1; }
ls tools/cloud/server.js >/dev/null || { echo 'Р С›Р РЃР ВР вЂР С™Р С’: Р Р† Р В°РЎР‚РЎвЂ¦Р С‘Р Р†Р Вµ Р Р…Р ВµРЎвЂљ tools/cloud/server.js РІР‚вЂќ РЎРѓР С•Р С•Р В±РЎвЂ°Р С‘РЎвЂљР Вµ Р С—Р С•Р СР С•РЎвЂ°Р Р…Р С‘Р С”РЎС“'; exit 1; }
echo '    Р В°РЎР‚РЎвЂ¦Р С‘Р Р† РЎР‚Р В°РЎРѓР С—Р В°Р С”Р С•Р Р†Р В°Р Р…, Р С”Р С•Р Т‘ РЎРѓР ВµРЎР‚Р Р†Р ВµРЎР‚Р В° РІР‚вЂќ Р Р…Р С•Р Р†РЎвЂ№Р в„–'
echo '=== 5/5 Р С’Р Р†РЎвЂљР С•Р В·Р В°Р С—РЎС“РЎРѓР С” РЎРѓР В»РЎС“Р В¶Р В±РЎвЂ№ Р С‘ HTTPS'
printf '%s\n' 'app.ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' 'ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' 'www.ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' > /etc/caddy/Caddyfile
systemctl restart caddy
printf '%s\n' '[Unit]' 'Description=II Master cloud' 'After=network.target' '' '[Service]' 'WorkingDirectory=/opt/ii-master/app' 'Environment=CLOUD_PORT=8790' 'Environment=CLOUD_DATA=/opt/ii-master/data' 'EnvironmentFile=-/opt/ii-master/pay.env' 'ExecStart=/usr/bin/node --no-warnings tools/cloud/server.js' 'Restart=always' 'RestartSec=5' '' '[Install]' 'WantedBy=multi-user.target' > /etc/systemd/system/ii-master.service
systemctl daemon-reload
systemctl enable ii-master
# Р вЂ™Р С’Р вЂ“Р СњР С›: Р С‘Р СР ВµР Р…Р Р…Р С• restart, Р В° Р Р…Р Вµ Р’В«enable --nowР’В» РІР‚вЂќ Р Т‘Р В»РЎРЏ РЎС“Р В¶Р Вµ Р В·Р В°Р С—РЎС“РЎвЂ°Р ВµР Р…Р Р…Р С•Р в„– РЎРѓР В»РЎС“Р В¶Р В±РЎвЂ№ Р’В«--nowР’В» Р Р…Р С‘РЎвЂЎР ВµР С–Р С• Р Р…Р Вµ Р С—Р ВµРЎР‚Р ВµР В·Р В°Р С—РЎС“РЎРѓР С”Р В°Р ВµРЎвЂљ,
# Р С‘ Р Р…Р В° РЎРѓР ВµРЎР‚Р Р†Р ВµРЎР‚Р Вµ Р С•РЎРѓРЎвЂљР В°РЎвЂРЎвЂљРЎРѓРЎРЏ РЎР‚Р В°Р В±Р С•РЎвЂљР В°РЎвЂљРЎРЉ РЎРѓРЎвЂљР В°РЎР‚РЎвЂ№Р в„– Р С”Р С•Р Т‘ (Р Р…Р В° РЎРЊРЎвЂљР С•Р С Р СРЎвЂ№ Р С—Р С•РЎвЂљР ВµРЎР‚РЎРЏР В»Р С‘ Р Р…Р ВµРЎРѓР С”Р С•Р В»РЎРЉР С”Р С• Р В·Р В°РЎвЂ¦Р С•Р Т‘Р С•Р Р† 02.10.2026).
systemctl restart ii-master
sleep 3
echo '=== Р СџРЎР‚Р С•Р Р†Р ВµРЎР‚Р С”Р В°:'
curl -s http://127.0.0.1:8790/api/health || { echo 'Р РЋР ВµРЎР‚Р Р†Р ВµРЎР‚ Р Р…Р Вµ Р С•РЎвЂљР Р†Р ВµРЎвЂљР С‘Р В». Р СџР С•Р Т‘РЎР‚Р С•Р В±Р Р…Р С•РЎРѓРЎвЂљР С‘: journalctl -u ii-master -n 20'; exit 1; }
echo ''
echo '=== Р СџРЎР‚Р С•Р Р†Р ВµРЎР‚Р С”Р В° Р Р…Р С•Р Р†РЎвЂ№РЎвЂ¦ Р Р†Р С•Р В·Р СР С•Р В¶Р Р…Р С•РЎРѓРЎвЂљР ВµР в„– (Р С•Р В¶Р С‘Р Т‘Р В°Р ВµР С cloud-v2 Р С‘ 401 РЎС“ Р В°Р Т‘РЎР‚Р ВµРЎРѓР В° Р С”Р С•Р С—Р С‘Р в„–):'
curl -s http://127.0.0.1:8790/api/health
echo ''
curl -s -o /dev/null -w '  Р В°Р Т‘РЎР‚Р ВµРЎРѓ Р С”Р С•Р С—Р С‘Р в„– Р Т‘Р В»РЎРЏ Р Р†Р В»Р В°Р Т‘Р ВµР В»РЎРЉРЎвЂ Р В°: %{http_code}  (401 - Р Р†РЎРѓРЎвЂ Р Р† Р С—Р С•РЎР‚РЎРЏР Т‘Р С”Р Вµ, 404 - Р С”Р С•Р Т‘ Р ВµРЎвЂ°РЎвЂ РЎРѓРЎвЂљР В°РЎР‚РЎвЂ№Р в„–)\n' \
  -X POST -H 'Content-Type: application/json' -d '{}' http://127.0.0.1:8790/api/backup/with-account
echo ''
echo '=== Р вЂќР Р…Р ВµР Р†Р Р…Р С•Р в„– Р В»Р С‘Р СР С‘РЎвЂљ РЎвЂљРЎР‚Р В°РЎвЂљ Р Р…Р В° РЎвЂЎР ВµР В»Р С•Р Р†Р ВµР С”Р В°: Р С—Р С• РЎС“Р СР С•Р В»РЎвЂЎР В°Р Р…Р С‘РЎР‹ 100 РІвЂљР….'
echo '=== Р ВР В·Р СР ВµР Р…Р С‘РЎвЂљРЎРЉ: echo "CLOUD_LIMIT_RUB=300" > /opt/ii-master/limit.env && systemctl restart ii-master'
echo '=== Р вЂўРЎРѓР В»Р С‘ Р Р†РЎвЂ№РЎв‚¬Р Вµ Р В±РЎвЂ№Р В»Р С• {"ok":true,...} РІР‚вЂќ РЎС“РЎРѓРЎвЂљР В°Р Р…Р С•Р Р†Р С”Р В° Р С—РЎР‚Р С•РЎв‚¬Р В»Р В° РЎС“РЎРѓР С—Р ВµРЎв‚¬Р Р…Р С•.'

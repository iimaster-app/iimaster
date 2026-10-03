#!/usr/bin/env bash
# РЈСЃС‚Р°РЅРѕРІРєР° РѕР±Р»Р°С‡РЅРѕРіРѕ СЃРµСЂРІРµСЂР° В«РР РњР°СЃС‚РµСЂВ» (РїРёР»РѕС‚). Ubuntu 24.04, Р·Р°РїСѓСЃРє РѕС‚ root.
# РљРѕСЂРѕС‚РєР°СЏ РєРѕРјР°РЅРґР° РґР»СЏ РІРµР±-РєРѕРЅСЃРѕР»Рё (РјРѕР¶РЅРѕ Р·Р°РїСѓСЃРєР°С‚СЊ РїРѕРІС‚РѕСЂРЅРѕ вЂ” РѕРЅР° СЃР°РјР° РІСЃС‘ РїРѕС‡РёРЅРёС‚):
#   curl -fsSL https://iimaster-app.github.io/iimaster/deploy/install.sh | bash
# РџСЂРёР»РѕР¶РµРЅРёРµ СЃС‚Р°РІРёС‚СЃСЏ РІ /opt/ii-master/app, РґР°РЅРЅС‹Рµ (Р±Р°Р·Р°) Р¶РёРІСѓС‚ РѕС‚РґРµР»СЊРЅРѕ РІ /opt/ii-master/data.
set -e
echo '=== 1/5 РћР±РЅРѕРІР»СЏСЋ СЃРїРёСЃРєРё РїР°РєРµС‚РѕРІ'
apt-get update -qq
echo '=== 2/5 РЎС‚Р°РІР»СЋ curl, unzip, Caddy'
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl unzip caddy ca-certificates
echo '=== 3/5 РЎС‚Р°РІР»СЋ Node 22 (РЅСѓР¶РµРЅ РґР»СЏ РІСЃС‚СЂРѕРµРЅРЅРѕР№ Р±Р°Р·С‹; СЃРёСЃС‚РµРјРЅС‹Р№ Node 18 РЅРµ РїРѕРґС…РѕРґРёС‚)'
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs
echo '=== 4/5 РЎРєР°С‡РёРІР°СЋ Рё СЂР°СЃРїР°РєРѕРІС‹РІР°СЋ РїСЂРёР»РѕР¶РµРЅРёРµ'
rm -rf /opt/ii-master/app
mkdir -p /opt/ii-master/app
cd /opt/ii-master/app
# ?v= вЂ” Р·Р°С‰РёС‚Р° РѕС‚ РєСЌС€Р°: Р±РµР· РЅРµРіРѕ GitHub РјРѕР¶РµС‚ РѕС‚РґР°С‚СЊ СЃС‚Р°СЂСѓСЋ РєРѕРїРёСЋ Р°СЂС…РёРІР°
curl -fsSL -o app.zip "https://iimaster-app.github.io/iimaster/deploy/ii-master-cloud-v5.zip"
unzip -oq app.zip
grep -q 'api/backup/with-account' tools/cloud/server.js || { echo 'РћРЁРР‘РљРђ: РІ Р°СЂС…РёРІРµ СЃС‚Р°СЂС‹Р№ РєРѕРґ СЃРµСЂРІРµСЂР° вЂ” СЃРѕРѕР±С‰РёС‚Рµ РїРѕРјРѕС‰РЅРёРєСѓ'; exit 1; }
ls tools/cloud/server.js >/dev/null || { echo 'РћРЁРР‘РљРђ: РІ Р°СЂС…РёРІРµ РЅРµС‚ tools/cloud/server.js вЂ” СЃРѕРѕР±С‰РёС‚Рµ РїРѕРјРѕС‰РЅРёРєСѓ'; exit 1; }
echo '    Р°СЂС…РёРІ СЂР°СЃРїР°РєРѕРІР°РЅ, РєРѕРґ СЃРµСЂРІРµСЂР° вЂ” РЅРѕРІС‹Р№'
echo '=== 5/5 РђРІС‚РѕР·Р°РїСѓСЃРє СЃР»СѓР¶Р±С‹ Рё HTTPS'
printf '%s\n' 'app.ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' 'ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' 'www.ii-master.ru {' '  reverse_proxy 127.0.0.1:8790' '}' > /etc/caddy/Caddyfile
systemctl restart caddy
printf '%s\n' '[Unit]' 'Description=II Master cloud' 'After=network.target' '' '[Service]' 'WorkingDirectory=/opt/ii-master/app' 'Environment=CLOUD_PORT=8790' 'Environment=CLOUD_DATA=/opt/ii-master/data' 'ExecStart=/usr/bin/node --no-warnings tools/cloud/server.js' 'Restart=always' 'RestartSec=5' '' '[Install]' 'WantedBy=multi-user.target' > /etc/systemd/system/ii-master.service
systemctl daemon-reload
systemctl enable ii-master
# Р’РђР–РќРћ: РёРјРµРЅРЅРѕ restart, Р° РЅРµ В«enable --nowВ» вЂ” РґР»СЏ СѓР¶Рµ Р·Р°РїСѓС‰РµРЅРЅРѕР№ СЃР»СѓР¶Р±С‹ В«--nowВ» РЅРёС‡РµРіРѕ РЅРµ РїРµСЂРµР·Р°РїСѓСЃРєР°РµС‚,
# Рё РЅР° СЃРµСЂРІРµСЂРµ РѕСЃС‚Р°С‘С‚СЃСЏ СЂР°Р±РѕС‚Р°С‚СЊ СЃС‚Р°СЂС‹Р№ РєРѕРґ (РЅР° СЌС‚РѕРј РјС‹ РїРѕС‚РµСЂСЏР»Рё РЅРµСЃРєРѕР»СЊРєРѕ Р·Р°С…РѕРґРѕРІ 02.10.2026).
systemctl restart ii-master
sleep 3
echo '=== РџСЂРѕРІРµСЂРєР°:'
curl -s http://127.0.0.1:8790/api/health || { echo 'РЎРµСЂРІРµСЂ РЅРµ РѕС‚РІРµС‚РёР». РџРѕРґСЂРѕР±РЅРѕСЃС‚Рё: journalctl -u ii-master -n 20'; exit 1; }
echo ''
echo '=== РџСЂРѕРІРµСЂРєР° РЅРѕРІС‹С… РІРѕР·РјРѕР¶РЅРѕСЃС‚РµР№ (РѕР¶РёРґР°РµРј cloud-v2 Рё 401 Сѓ Р°РґСЂРµСЃР° РєРѕРїРёР№):'
curl -s http://127.0.0.1:8790/api/health
echo ''
curl -s -o /dev/null -w '  Р°РґСЂРµСЃ РєРѕРїРёР№ РґР»СЏ РІР»Р°РґРµР»СЊС†Р°: %{http_code}  (401 - РІСЃС‘ РІ РїРѕСЂСЏРґРєРµ, 404 - РєРѕРґ РµС‰С‘ СЃС‚Р°СЂС‹Р№)\n' \
  -X POST -H 'Content-Type: application/json' -d '{}' http://127.0.0.1:8790/api/backup/with-account
echo ''
echo '=== Р”РЅРµРІРЅРѕР№ Р»РёРјРёС‚ С‚СЂР°С‚ РЅР° С‡РµР»РѕРІРµРєР°: РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ 100 в‚Ѕ.'
echo '=== РР·РјРµРЅРёС‚СЊ: echo "CLOUD_LIMIT_RUB=300" > /opt/ii-master/limit.env && systemctl restart ii-master'
echo '=== Р•СЃР»Рё РІС‹С€Рµ Р±С‹Р»Рѕ {"ok":true,...} вЂ” СѓСЃС‚Р°РЅРѕРІРєР° РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ.'

USER_INFO=`curl --fail --silent 'https://nordvpn.com/wp-admin/admin-ajax.php?action=get_user_info_data' 2> /dev/null`
# {
#   "coordinates": {
#     "latitude": 51.2198,
#     "longitude": 4.4671
#   },
#   "ip": "81.165.8.171",
#   "isp": "Telenet",
#   "host": {
#     "domain": "telenet.be",
#     "ip_address": "81.165.8.171"
#   },
#   "status": false,
#   "country": "Belgium",
#   "region": "Antwerp Province",
#   "city": "Deurne",
#   "location": "Belgium, Antwerp Province, Deurne",
#   "area_code": "2100",
#   "country_code": "BE"
# }

CONNECTED=`echo "$USER_INFO" | jq '.status'`
IP=`echo "$USER_INFO" | jq -r '.ip'`
ISP=`echo "$USER_INFO" | jq -r '.isp'`
COUNTRY=`echo "$USER_INFO" | jq -r '.country'`
COUNTRY_CODE=`echo "$USER_INFO" | jq -r '.country_code'`

if [[ "$CONNECTED" == "true" ]]; then
  echo "vpn: $COUNTRY_CODE ($IP)"
  echo "vpn: $COUNTRY_CODE"
  echo "#00CC00"
  # echo "#000000"
else
  echo "vpn: off ($IP)"
  echo "vpn: off"
  echo "#FF0000"
  # echo "#000000"
fi
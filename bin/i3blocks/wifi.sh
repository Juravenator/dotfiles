DEFAULT_GATEWAY_INTERFACE="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
IPV4_ADDR="$(ip -4 addr show dev $DEFAULT_GATEWAY_INTERFACE | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }' | head -1)"
IPV6_ADDR="$(ip -6 addr show dev $DEFAULT_GATEWAY_INTERFACE | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }' | head -1)"

if [[ "$DEFAULT_GATEWAY_INTERFACE" == "" ]]; then
  echo "not connected"
  exit 33
fi

WIFI_INTERFACE=$(iw dev | awk '$1=="Interface"{print $2}')

if [[ "$DEFAULT_GATEWAY_INTERFACE" != "$WIFI_INTERFACE" ]]; then
  echo -n "eth: "
  if [[ "$IPV6_ADDR" != "" ]]; then
    echo -n "(IPv6) "
  fi
  echo "$IPV4_ADDR"
  exit 0
fi

SSID=`iwgetid -r`
CONN_INFO=`nmcli connection show $SSID`
BITRATE=`iw dev $WIFI_INTERFACE link | grep -F "rx bitrate:" | cut -d ' ' -f3-`

if [[ "$SSID" == "" ]]; then
  echo "WiFi: off"
  echo "WiFi: off"
  echo "#ff0000"
  # echo "#000000"
  exit
fi

FULL_TEXT="$SSID [$BITRATE] [$IPV4_ADDR]"
SHORT_TEXT="$SSID"
if [[ "$IPV6_ADDR" != "" ]]; then
  FULL_TEXT="$FULL_TEXT [ipv6]"
fi

echo "$FULL_TEXT"
echo "$SHORT_TEXT"
# echo "#FFFFFF"
# echo "#006b1b"
echo "#00CC00"
# echo "#000000"
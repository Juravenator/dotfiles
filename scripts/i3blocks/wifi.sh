SSID=`iwgetid -r`
CONN_INFO=`nmcli connection show $SSID`
# INTERFACE_NAME=`cat /proc/net/wireless | tail -1 | cut -d: -f1`
IPV4_ADDR=`echo "$CONN_INFO" | grep -F "IP4.ADDRESS[1]:" | rev | cut -d ' ' -f1 | rev | cut -d'/' -f1`
INTERFACE_NAME=`echo "$CONN_INFO" | grep -F "GENERAL.IP-IFACE:" | rev | cut -d ' ' -f1 | rev | cut -d'/' -f1`
IPV6_ACTIVE=`echo "$CONN_INFO" | grep -F "GENERAL.DEFAULT6:" | rev | cut -d ' ' -f1 | rev | cut -d'/' -f1`
BITRATE=`iw dev $INTERFACE_NAME link | grep -F "rx bitrate:" | cut -d ' ' -f3-`

if [[ "$SSID" == "" ]]; then
  echo "WiFi: off"
  echo "WiFi: off"
  echo "#ff0000"
  # echo "#000000"
  exit
fi

FULL_TEXT="$SSID [$BITRATE] [$IPV4_ADDR]"
SHORT_TEXT="$SSID"
if [[ "$IPV6_ACTIVE" == "yes" ]]; then
  FULL_TEXT="$FULL_TEXT [ipv6]"
fi

echo "$FULL_TEXT"
echo "$SHORT_TEXT"
# echo "#FFFFFF"
# echo "#006b1b"
echo "#00CC00"
# echo "#000000"
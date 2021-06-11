# JSON=`curl 'wttr.in?format=j1'`

ICON_SUN=""
ICON_MOON=""
ICON_UMBRELLA=""
ICON_TINT=""
ICON_ARROW_UP=""
ICON_ARROW_DOWN=""

# ☀️::+19°C::+19°C::↙7km/h::🌒::3::0.4mm::::1016hPa::07:25:50::19:43:50
DATA=`curl --silent --fail wttr.in?format="%C::%t::%f::%w::%m::%M::%p::%o::%P::%S::%s"`

# DATA="☀::+19°C::+19°C::↙7km/h::🌒::3::0.4mm::::1016hPa::07:25:50::19:43:50"

WEATHER_ICON=`echo "$DATA" | cut -d':' -f1`
TEMP_ACTUAL=`echo "$DATA" | cut -d':' -f3`
TEMP_ACTUAL="${TEMP_ACTUAL#+}"
TEMP_FEEL=`echo "$DATA" | cut -d':' -f5`
TEMP_FEEL="${TEMP_FEEL#+}"
WIND=`echo "$DATA" | cut -d':' -f7`
MOONPHASE_ICON=`echo "$DATA" | cut -d':' -f9`
MOON_DAY=`echo "$DATA" | cut -d':' -f11`
PRECIPATION=`echo "$DATA" | cut -d':' -f13`
PRECIPATION_PROB=`echo "$DATA" | cut -d':' -f15`
PRESSURE=`echo "$DATA" | cut -d':' -f17`
SUNRISE_TIME=`echo "$DATA" | cut -d':' -f19,20`
SUNSET_TIME=`echo "$DATA" | cut -d':' -f23,24`

SUMMARY="${MOONPHASE_ICON} | ${WEATHER_ICON} $TEMP_ACTUAL"
if [[ "$TEMP_ACTUAL" != "$TEMP_FEEL" ]]; then
  SUMMARY="$SUMMARY($TEMP_FEEL)"
fi

FULL_TEXT="${SUMMARY} | $WIND | ${ICON_TINT} ${PRECIPATION}"
if [[ -n "$PRECIPATION_PROB" ]]; then
  FULL_TEXT="$FULL_TEXT($PRECIPATION_PROB)"
fi
FULL_TEXT="$FULL_TEXT | ${ICON_ARROW_UP}${SUNRISE_TIME} ☀ ${SUNSET_TIME}${ICON_ARROW_DOWN}"

echo "$FULL_TEXT"
echo "$SUMMARY"
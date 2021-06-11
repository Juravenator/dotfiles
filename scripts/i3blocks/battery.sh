# https://fontawesome.com/cheatsheet/free/solid
ICON_BATTERY_EMPTY=""
ICON_BATTERY_QUARTER=""
ICON_BATTERY_HALF=""
ICON_BATTERY_THREE_QUARTERS=""
ICON_BATTERY_FULL=""
ICON_PLUG=""
ICON_BOLT=""
ICON_PLUS_SQUARE=""
ICON_REDO=""
ICON_SYNC=""


# CHARGE_PERCENT=`cat /sys/class/power_supply/BAT0/capacity`
CYCLE_COUNT=`cat /sys/class/power_supply/BAT0/cycle_count`
STATUS=`cat /sys/class/power_supply/BAT0/status`

MAX_CAPACITY=`cat /sys/class/power_supply/BAT0/charge_full`
MAX_CAPACITY_ORIGINAL=`cat /sys/class/power_supply/BAT0/charge_full_design`
HEALTH_PERCENT=$(( MAX_CAPACITY*100/MAX_CAPACITY_ORIGINAL ))
HEALTH_PERCENT=`printf "%0.0f" $HEALTH_PERCENT`

# Charging, 98%, 00:10:27 until charged
ACPI=`acpi | head -1 | cut -d' ' -f3-`
CHARGE_PERCENT=`echo $ACPI | cut -d' ' -f2`
CHARGE_PERCENT="${CHARGE_PERCENT%,}"
TIME_REMAINING=`echo $ACPI | cut -d' ' -f3`

STATE_ICONS=""
if [[ "$STATUS" == "Charging" ]]; then
  STATE_ICONS="${ICON_BOLT}${ICON_PLUG}"
elif [[ "$STATUS" == "Full" ]]; then
  STATE_ICONS="${ICON_PLUG}"
fi

BATTERY_ICON=""
CHARGE_PERCENT_RAW="${CHARGE_PERCENT%\%}"
if [[ "${CHARGE_PERCENT_RAW}" -lt "30" ]]; then
  BATTERY_ICON="$ICON_BATTERY_EMPTY"
elif [[ "${CHARGE_PERCENT_RAW}" -lt "50" ]]; then
  BATTERY_ICON="$ICON_BATTERY_QUARTER"
elif [[ "${CHARGE_PERCENT_RAW}" -lt "70" ]]; then
  BATTERY_ICON="$ICON_BATTERY_HALF"
elif [[ "${CHARGE_PERCENT_RAW}" -lt "90" ]]; then
  BATTERY_ICON="$ICON_BATTERY_THREE_QUARTERS"
else
  BATTERY_ICON="$ICON_BATTERY_FULL"
fi

SUMMARY="$STATE_ICONS ${CHARGE_PERCENT}"
if [[ -n "$TIME_REMAINING" ]]; then
  SUMMARY="$SUMMARY ($TIME_REMAINING)"
fi
FULL_TEXT="$SUMMARY ($ICON_PLUS_SQUARE $HEALTH_PERCENT%, $ICON_REDO $CYCLE_COUNT)"

echo "$FULL_TEXT"
echo "$SUMMARY"
if [[ "$STATUS" == "Full" ]]; then
  echo "#00CC00"
else
  echo "#FFFFFF"
fi
# echo "#000000"

if [[ "${CHARGE_PERCENT_RAW}" -lt "30" ]]; then
  exit 33
fi
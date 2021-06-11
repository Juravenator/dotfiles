MEMINFO=`cat /proc/meminfo`
MEMTOTAL=`echo "$MEMINFO" | grep MemTotal | rev | cut -d' ' -f2 | rev`
MEMAVAILABLE=`echo "$MEMINFO" | grep MemAvailable | rev | cut -d' ' -f2 | rev`

AVAILABLE_PERCENT=`printf "%0.0f\n" $((MEMAVAILABLE*100/MEMTOTAL))`
FREE_READABLE=`free -h | grep Mem | rev | cut -d' ' -f1 | rev`

echo "$FREE_READABLE ($AVAILABLE_PERCENT%)"
if [[ "$AVAILABLE_PERCENT" -lt "20" ]]; then
  exit 33
fi
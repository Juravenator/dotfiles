OUTPUT=`sensors`
RPM=`echo "$OUTPUT" | grep RPM | cut -d' ' -f5,6`
TEMP=`echo "$OUTPUT" | grep 'Package id 0' | cut -d' ' -f5`

RAWTEMP=`echo ${TEMP#+} | cut -d'.' -f1`

echo "${TEMP#+} $RPM"
echo "${TEMP#+}"
if [[ "$RAWTEMP" -gt 70 ]]; then
  echo "#FF0000"
fi
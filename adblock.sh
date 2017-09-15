#!/bin/ash
HOSTS=/tmp/block.hosts
THRESHOLD=65000
TMP_HOSTS=/tmp/block.hosts.unsorted

# If a block.hosts file already exists...
if [ -f ${HOSTS} ]
then
	EXISTING_HOSTS_LINE_COUNT=`wc -l ${HOSTS} | awk '{print $1}'`
	YOUNG_FILE=`find ${HOSTS} -mtime -14 -print0`
	# Do not re-create block.hosts if file younger than 14 days, OR the file didn't meet the minimum lines threshold
	if [ -f "${YOUNG_FILE}" ] && [ ${EXISTING_HOSTS_LINE_COUNT} -ge ${THRESHOLD} ] ;
	then
		logger "Adblock.sh: skipping download"
		exit 0
	fi
fi

# remove any old TMP_HOSTS that might have stuck around
rm ${TMP_HOSTS} 2> /dev/null

for URL in \
    "http://adaway.org/hosts.txt" \
    "http://www.malwaredomainlist.com/hostslist/hosts.txt" \
    "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" \
    "http://someonewhocares.org/hosts/hosts" \
    "http://hosts-file.net/ad_servers.txt" \
    "http://winhelp2002.mvps.org/hosts.txt"
do
    wget -qO- "${URL}" | awk '/^(127|0)\.0\.0\.(0|1)/{print "0.0.0.0",$2}' >> ${TMP_HOSTS}
done

LINES=`wc -l ${TMP_HOSTS} | awk '{print $1}'`
# Test if threshold met
if [ ${LINES} -ge ${THRESHOLD} ]
then
    # remove duplicate hosts and save the real hosts file
	sort -u ${TMP_HOSTS} > ${HOSTS}
	logger "Adblock.sh: ${HOSTS} re-created"
else
    logger "Adblock.sh: ${TMP_HOSTS} has fewer than ${THRESHOLD} lines - leaving old HOSTS alone"
fi

rm ${TMP_HOSTS} 2> /dev/null

killall -s SIGHUP dnsmasq

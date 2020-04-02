#!/bin/ash
HOSTS=/tmp/block.hosts
STALE_DAYS=14
THRESHOLD=65000
TMP_HOSTS=/tmp/block.hosts.unsorted

if [ $# -eq 0 ]
then
	# If a block.hosts file already exists...
	if [ -f ${HOSTS} ]
	then
		EXISTING_HOSTS_LINE_COUNT=`wc -l ${HOSTS} | awk '{print $1}'`
		YOUNG_FILE=`find ${HOSTS} -mtime -${STALE_DAYS} -print0`
		# Only update the file if it's considered old, unless the file didn't meet the lines threshold
		if [ -f "${YOUNG_FILE}" ] && [ ${EXISTING_HOSTS_LINE_COUNT} -ge ${THRESHOLD} ] ;
		then
			logger "Adblock.sh: skipping download"
			exit 0
		fi
	fi
elif [ $# -gt 0 -a "$1" = '--force' ]
then
	#  Colon when the shell syntax requires a command but you have nothing to do
	:
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
# Test if threshold met or hosts file doesn't exist
if [ ${LINES} -ge ${THRESHOLD} ] || [ ! -f ${HOSTS} ]
then
    # remove duplicate hosts and save the real hosts file
	nice -n19 sort -u ${TMP_HOSTS} > ${HOSTS}
	logger "Adblock.sh: ${HOSTS} re-created"
else
    logger "Adblock.sh: ${TMP_HOSTS} has fewer than ${THRESHOLD} lines - leaving old HOSTS alone"
fi

rm ${TMP_HOSTS} 2> /dev/null

killall -s SIGHUP dnsmasq

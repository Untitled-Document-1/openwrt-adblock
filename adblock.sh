#!/bin/ash

TMP_HOSTS=/tmp/block.hosts.unsorted
HOSTS=/tmp/block.hosts

# remove any old TMP_HOSTS that might have stuck around
rm ${TMP_HOSTS} 2> /dev/null

for URL in \
    "http://adaway.org/hosts.txt" \
    "http://www.malwaredomainlist.com/hostslist/hosts.txt" \
    "https://hosts-file.net/ad_servers.txt" \
    "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" \
    "http://someonewhocares.org/hosts/hosts" \
    "http://hosts-file.net/ad_servers.txt" \
    "http://winhelp2002.mvps.org/hosts.txt"
do
    # grab a hosts file and...
    # filter out comment lines
    # filter out empty lines
    # filter out localhost entries (the router is handling localhost)
    # replace 127.0.0.1 with 0.0.0.0
    # remove trailing comments
    # replace tabs with spaces
    # replace double+ spaces with single spaces
    # remove carriage returns
    # append the results to TMP_HOSTS
    wget -qO- "${URL}" | grep -v -e "^#" -e "^\s*$" -e "\blocalhost\b" | sed -E -e "s/^127.0.0.1/0.0.0.0/" -e "s/#.*$//" -e "s/\t/ /" -e "s/[[:space:]]{2,}/ /" | tr -d "\r" >> ${TMP_HOSTS}

# this does all of that, plus it adds an entry for ipv6 using ::1 as the address...
# but it also has the side effect of making dnsmasq crash every 10 - 120 minutes on my wrt1900ac
#    wget -qO- "${URL}" | grep -v -e "^#" -e "^$" -e localhost | sed -E -e "s/^127.0.0.1/0.0.0.0/" -e "s/#.*$//" -e "s/\t/ /" -e "s/  / /" -e "s/ (.+)/ \1\n::1 \1/" | tr -d "\r" >> ${TMP_HOSTS}

done

lines=`wc -l ${TMP_HOSTS} | awk '{print $1}'`

# Number of lines is 69313 as of 1 July 2016. A minimum of 65000 seems like a good indicator of success.
if [ $lines -ge 65000 ]
then
    # remove duplicate hosts and save the real hosts file
    sort ${TMP_HOSTS} | uniq > ${HOSTS}
else
    logger "Adblock.sh: TMP_HOSTS has fewer than 45000 lines - leaving old HOSTS alone"
fi

rm ${TMP_HOSTS} 2> /dev/null

killall -s SIGHUP dnsmasq

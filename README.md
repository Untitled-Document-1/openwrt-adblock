# openwrt-adblock
hosts file based ad blocking for OpenWRT

####To use it:

* Download the ad block script, save it to /etc/, and make it executable.
```
wget --no-check-certificate https://raw.githubusercontent.com/Untitled-Document-1/openwrt-adblock/master/adblock.sh -O /etc/adblock.sh
chmod +x /etc/adblock.sh
```

* Tell dnsmasq to use the hosts that adblock.sh generates.
* If you have LuCI, Network > DHCP and DNS > Resolv and Hosts Files > Additional Hosts files
```
/tmp/block.hosts
```
* If you don't, add the following to /etc/config/dhcp under 'config dnsmasq'
```
list addnhosts '/tmp/block.hosts'
```

* Run the adblock script.
```
/etc/adblock.sh
```

####Run on boot.
* Add the following to /etc/rc.local (In LuCI, it's System > Startup) [the sleep is to make sure that your connection is fully up - the sleep period may need to be increased for slower routers and connections]
```
sleep 15 && /etc/adblock.sh &
```

####Prerequisites
* Make sure you have the necessary SSL root certificates. This will prevent a "wget: can't execute 'openssl': No such file or directory" error when the script attempts to download the hosts-file.net list.

```
opkg update
opkg install wget ca-certificates
```

####Optional - serve a 1 pixel transparent .gif for all of the newly un-routable things.
```
wget --no-check-certificate -O /www/1.gif http://upload.wikimedia.org/wikipedia/commons/c/ce/Transparent.gif
uci set uhttpd.main.error_page="/1.gif" && uci commit
/etc/init.d/uhttpd restart
```

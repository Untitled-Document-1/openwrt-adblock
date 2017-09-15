# openwrt-adblock
Hosts file based ad blocking for OpenWRT / LEDE

#### Prerequisites ####
* Make sure you have the necessary SSL root certificates. This will prevent a possible "wget: can't execute 'openssl': No such file or directory" error when the script attempts to download the hosts-file.net list.

```
opkg update
opkg install wget ca-certificates
```

#### To use it ####

* Download the ad block script, save it to ```/etc```, and make it executable.
```
wget --no-check-certificate https://raw.githubusercontent.com/Untitled-Document-1/openwrt-adblock/master/adblock.sh -O /etc/adblock.sh
chmod +x /etc/adblock.sh
```

* Tell dnsmasq to use the hosts that ```adblock.sh``` generates:
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

#### Run on boot ####
* Add the following to ```/etc/rc.local``` (In LuCI, it's System > Startup) [the sleep is to make sure that your connection is fully up - the sleep period may need to be increased for slower routers and connections]
```
sleep 60 && /etc/adblock.sh &
```
#### Alternatively: add a cron job ####
* If your router is not restarted very often then a cron job may more suitable for keeping the blocked hosts file up-to-date. The following example shows a cron job that runs at 4am every day.
````
0 4 * * * /etc/adblock.sh
````
Please note: in the above example, even though the script is scheduled to run everyday, the script contains a conditional that considers the existing blocked hosts file to be stale after 14 days. Only after 14 days will the file be re-created from the up-to-date lists. If you feel 14 days is too long and you want your file updated more frequently, then edit the script (```STALE_DAYS``` variable).

#### Optional - serve a 1 pixel transparent .gif for all of the newly un-routable things ####
```
wget --no-check-certificate -O /www/1.gif http://upload.wikimedia.org/wikipedia/commons/c/ce/Transparent.gif
uci set uhttpd.main.error_page="/1.gif" && uci commit
/etc/init.d/uhttpd restart
```

# openwrt-adblock
Hosts file based ad blocking for OpenWRT / LEDE

#### Prerequisites ####
* Make sure you have the necessary SSL root certificates. This will prevent a possible ```wget: can't execute 'openssl': No such file or directory``` error when the script attempts to download the hosts-file.net list.

```
opkg update
opkg install wget ca-certificates
```

#### To use it ####

* Download the ad block script, save it to ```/etc```, and make it executable:
```
wget --no-check-certificate https://raw.githubusercontent.com/Untitled-Document-1/openwrt-adblock/master/adblock.sh -O /etc/adblock.sh
chmod +x /etc/adblock.sh
```

* Tell dnsmasq to use the blocked hosts file that ```adblock.sh``` generates:
    * If you have LuCI, navigate to ```Network``` > ```DHCP and DNS``` > ```Resolv and Hosts Files``` tab > ```Additional Hosts files``` field. Add the following:
    ```
    /tmp/block.hosts
    ```
    * If you don't have LuCI, add the following to ```/etc/config/dhcp``` under ```config dnsmasq```:
    ```
    list addnhosts '/tmp/block.hosts'
    ```

* Run the adblock script:
```
/etc/adblock.sh
```

Note: you can now skip the age and lines threshold checks with the ```--force``` option.

#### Run on boot ####
* Add the following to ```/etc/rc.local``` (In LuCI, it's System > Startup)  
[the sleep is to make sure that your connection is fully up - the sleep period may need to be increased for slower routers and connections]
```
sleep 60 && /etc/adblock.sh &
```
#### Alternatively: add a cron job ####
* If your router is not restarted very often then a cron job may more suitable for keeping the blocked hosts file up-to-date. The following example shows a cron job that runs the script at 4am every day:
````
0 4 * * * /etc/adblock.sh
````
Please note: even though the script may be scheduled to run every day, the script contains a conditional that checks the ```Last modified``` date of the pre-existing blocked hosts file. Only if the file is older than 14 days will the file be re-created from the up-to-date lists. If you feel 14 days is too long and you want the file updated more frequently, then edit the script, changing the ```STALE_DAYS``` variable value to e.g. ```7```.

#### Optional - serve a 1 pixel transparent .gif for all of the newly un-routable things ####
```
wget --no-check-certificate -O /www/1.gif http://upload.wikimedia.org/wikipedia/commons/c/ce/Transparent.gif
uci set uhttpd.main.error_page="/1.gif" && uci commit
/etc/init.d/uhttpd restart
```

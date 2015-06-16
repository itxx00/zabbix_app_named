# zabbix_app_named
zabbix template to monitor bind9 named service

# How to use (tested on CentOS7)
the monitor script need to use zabbix-sender

bash```
yum install zabbix-sender
```

configure named.conf in _options_ section:

```
statistics-file "/var/named/data/named_stats.txt";
```

import template xml in zabbix dashboard and,
create a crontab on named server

```
cat >/etc/cron.d/zabbix-named <<EOF
* * * * * root /opt/zabbix/zabbix-named.sh >/dev/null 2>&1 &
EOF
```

#!/bin/bash
# send named metrics to zabbix

ZAB_CONF=/etc/zabbix/zabbix_agentd.conf
ZAB_BIN=/usr/bin/zabbix_sender
RNDC_BIN=/usr/sbin/rndc
STATS='/var/named/data/named_stats.txt'
TMP_FILE=$(mktemp)

rm -f $STATS
if ! $RNDC_BIN stats; then
    exit 1
fi
if [ -s ${STATS} ]; then
    named_total_query=$(awk '/ QUERY/ {print $1}' $STATS)
    named_tcp_request=$(awk '/ TCP requests received/ {print $1}' $STATS)
    named_total_response=$(awk '/[0-9] responses sent/ {print $1}' $STATS)
    named_success_query=$(awk '/queries resulted in successful/ {print $1}' $STATS)
    named_dropped_query=$(awk '/ queries dropped/ {print $1}' $STATS)
    echo "- named_total_query $named_total_query" >$TMP_FILE
    echo "- named_tcp_request $named_tcp_request" >>$TMP_FILE
    echo "- named_total_response $named_total_response" >>$TMP_FILE
    echo "- named_success_query $named_success_query" >>$TMP_FILE
    echo "- named_dropped_query $named_dropped_query" >>$TMP_FILE
    if tty >/dev/null; then
        cat ${TMP_FILE}
        $ZAB_BIN -vv -c ${ZAB_CONF} -i ${TMP_FILE}
    else
        $ZAB_BIN -c ${ZAB_CONF} -i ${TMP_FILE} >/dev/null
    fi
    rm -f ${TMP_FILE}
elif tty >/dev/null ; then
    echo "${STATS} does not exist!" >&2
    rm -f ${TMP_FILE}
    exit 1
fi

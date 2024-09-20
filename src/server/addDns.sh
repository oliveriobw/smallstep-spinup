

jq '.dnsNames[.dnsNames|length]+="yabc"' deploy/abcdefg_vol/config/ca.json 

stop - restart server
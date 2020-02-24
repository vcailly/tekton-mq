#!/bin/bash
tput reset
echo 'dn: olcDatabase={1}mdb, cn=config' >/tmp/config.ldif
echo 'changetype: modify' >>/tmp/config.ldif
echo 'add: olcAccess' >>/tmp/config.ldif
echo 'olcAccess: {1}to * by self read by dn="cn=admin,dc=example,dc=org" write by * read' >>/tmp/config.ldif
echo '-' >>/tmp/config.ldif
echo 'add: olcDbIndex' >>/tmp/config.ldif
echo 'olcDbIndex: cn eq' >>/tmp/config.ldif
echo '-' >>/tmp/config.ldif
echo 'add: olcDbIndex' >>/tmp/config.ldif
echo 'olcDbIndex: member eq' >>/tmp/config.ldif
echo '' >>/tmp/config.ldif

ldapmodify  -h localhost -D cn=admin,cn=config -w config -p 389  -f /tmp/config.ldif


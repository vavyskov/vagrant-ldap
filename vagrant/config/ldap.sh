#!/bin/bash
set -eux

apt-get update
#apt-get upgrade -y

## Variables
ORGANIZATION_NAME=Example
DOMAIN=$(hostname --domain)
DOMAIN_DC="dc=$(echo $DOMAIN | sed 's/\./,dc=/g')"
ADMIN_DN="cn=admin,$DOMAIN_DC"
ADMIN_PASSWORD=ldap
#FQDN=$(hostname --fqdn)





## ToDo: Change "cn=admin -> cn=ldap"





## Configuration
##
## debconf-show slapd
## debconf-get-selections | grep -E '^slapd\s+' | sort
##
apt-get install -y debconf-utils

debconf-set-selections <<EOF
slapd slapd/password1 password $ADMIN_PASSWORD
slapd slapd/password2 password $ADMIN_PASSWORD
slapd slapd/domain string $DOMAIN
slapd shared/organization string $ORGANIZATION_NAME
EOF

## Instalation
apt-get install -y slapd ldap-utils

sed -i 's/#BASE.*dc=example,dc=com/BASE\tdc=example,dc=com/' /etc/ldap/ldap.conf
sed -i 's/#URI.*ldap.example.com.*ldap:\/\/ldap-master.example.com:666/URI\tdevel.example.com ldap:\/\/devel.example.com:666/' /etc/ldap/ldap.conf

#service slapd restart

## Test LDAP
#ldapsearch -x

## Test LDAP connection ("anonymous" is the result we're expecting)
#ldapwhoami -H ldap:// -x

## Reconfiguration
#dpkg-reconfigure slapd
#dpkg-reconfigure -f noninteractive slapd

## -----------------------------------------------------------------------------

## LDAP Account Manager (default PASSWORD for "lam" user is "lam")
apt-get install -y ldap-account-manager php-xml php-zip

service apache2 reload

## LDAP Account Manager - configuration
sed -i 's/admins: cn=Manager,dc=my-domain,dc=com/admins: cn=admin,dc=example,dc=com/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/treesuffix: dc=yourdomain,dc=org/treesuffix: dc=example,dc=com/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/ou=People/ou=people/' /var/lib/ldap-account-manager/config/lam.conf
sed -i 's/dc=my-domain,dc=com/dc=example,dc=com/g' /var/lib/ldap-account-manager/config/lam.conf
#sed -i 's/defaultLanguage: en_GB.utf8:UTF-8:English (Great Britain)/defaultLanguage: cs_CZ.utf8:UTF-8:Čeština (Česko)/' /var/lib/ldap-account-manager/config/lam.conf

## Change default port from 80 to 8080
sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
sed -i 's/:80/:8080/' /etc/apache2/sites-available/000-default.conf
#sed -ie "s/\(Listen 80\)/\180/g" /etc/apache2/ports.conf
#sed -ie "s/\(\*:80\)/\180/g" /etc/apache2/sites-available/000-default.conf

## Change URL from "/lam" to "/"
echo "Alias / /usr/share/ldap-account-manager/" >> /etc/apache2/sites-available/000-default.conf

## Service
service apache2 reload

## -----------------------------------------------------------------------------

## Import data from file
ldapadd -c -D cn=admin,dc=example,dc=com -w ldap -f /vagrant/config/data.ldif





## Import data from script

## Initialize group
#ldapadd -c -D $ADMIN_DN -w $ADMIN_PASSWORD <<EOF
#dn: ou=group,$DOMAIN_DC
#objectClass: organizationalUnit
#ou: group
#EOF

## Add group
#ldapadd -c -D $ADMIN_DN -w $ADMIN_PASSWORD <<EOF
#dn: cn=nas,ou=group,$DOMAIN_DC
#objectClass: posixGroup
#gidNumber: 400
#description: NAS group
#memberUid: alice
#memberUid: bob
#EOF

## Initialize people
#ldapadd -c -D $ADMIN_DN -w $ADMIN_PASSWORD <<EOF
#dn: ou=people,$DOMAIN_DC
#objectClass: organizationalUnit
#ou: people
#EOF

## Add people
#function add_person {
#    local n=$1; shift
#    local name=$1; shift
#    ldapadd -c -D $ADMIN_DN -w $ADMIN_PASSWORD <<EOF
#dn: uid=$name,ou=people,$DOMAIN_DC
#objectClass: inetOrgPerson
#userPassword: $(slappasswd -s password)
#uid: $name
#mail: $name@$DOMAIN
#cn: $name doe
#givenName: $name
#sn: doe
#telephoneNumber: +420 888 555 00$((n+1))
##labeledURI: http://example.com/~$name Personal Home Page
#jpegPhoto::$(base64 -w 66 /vagrant/config/people/person-$(n+1).jpg | sed 's,^, ,g')
#EOF
#}
#people=(alice bob carol dave eve frank grace henry)
#for n in "${!people[@]}"; do
#    add_person $n "${people[$n]}"
#done





## Test
#ldapsearch -x -w "ldap" -D cn=admin,dc=example,dc=com -b "ou=people,dc=example,dc=com" inetOrgPerson

## Show the data tree
#ldapsearch -x -LLL -b $DOMAIN_DC dn | grep -v '^$'
#ldapsearch -x -LLL -b dc=example,dc=com dn | grep -v '^$'

## Search for people and print some of their attributes
#ldapsearch -x -LLL -b $DOMAIN_DC '(objectClass=person)' cn mail
#ldapsearch -x -LLL -b dc=example,dc=com '(objectClass=person)' cn mail

## -----------------------------------------------------------------------------

## Fix disk fragmentation (increases compression efficiency)
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY
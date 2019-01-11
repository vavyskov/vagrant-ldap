
# vagrant-ldap

Debian OpenLDAP and LDAP Account Manager stack

## Usage

1. Open the terminal and navigate to the directory containing the `Vagrant` file.

1. Run `vagrant up` to configure the `ldap.example.com` server environment.

1. Open the web browser:

    LDAP Account Manager:
    - URL: `localhost:8020` or `192.168.33.20:8020`
    - LAM login
      - User: `admin`
      - Password: `ldap`
      - Server: `ldap://localhost:389`
    - LAM configuration
      - User: `lam` (LAM configuration)
      - Password: `lam` (LAM configuration)

1. Optionally configure your system `hosts` file:

    192.168.33.20 ldap.example.com

    Path:
    - Linux: `/etc/hosts`
    - macOX: `/private/etc/hosts`
    - Windows: `C:\Windows\System32\drivers\etc\hosts`

## The OpenLDAP comes with pre-configured the following entries

    uid=user1,ou=people,dc=example,dc=com
    uid=user2,ou=people,dc=example,dc=com

    cn=nas,ou=group,dc=example,dc=com
    
## LDAP server access

 - Server URL: `192.168.33.20`
 - Server port: `389`
 - Base DN: `dc=example,dc=com`
 - Username: `cn=admin,dc=example,dc=com`
 - Password: `ldap`

Command line access test:

    ldapsearch -h 192.168.33.20 -p 389 -D "cn=admin,dc=example,dc=com" -w ldap


# vagrant-ldap

Debian OpenLDAP and LDAP Account Manager stack

## Usage

### 1. Open the terminal and navigate to the directory containing the `Vagrant` file.

### 2. Run `vagrant up` to configure the `ldap.example.com` server environment.

### 3. Open the web browser:

LDAP Account Manager:
- URL: `localhost:8080` or `192.168.33.20:8080`
  - LAM login
    - User: `admin`
    - Password: `ldap`
    - Server: `ldap://localhost:389`
  - LAM configuration
    - User: `lam` (LAM configuration)
    - Password: `lam` (LAM configuration)

### 4. Optionally configure your system `hosts` file

    192.168.33.20 ldap.example.com

Path:
- Linux: `/etc/hosts`
- macOX: `/private/etc/hosts`
- Windows: `C:\Windows\System32\drivers\etc\hosts`

### 5. The OpenLDAP comes with pre-configured the following entries:

    uid=user1,ou=people,dc=example,dc=com
    uid=user2,ou=people,dc=example,dc=com

    cn=nas,ou=group,dc=example,dc=com
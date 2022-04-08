#!/usr/bin/bash

separador () {
 echo -e "\n----------------------------------------------------------------------"
 echo -e "           $1   "
 echo -e "\n"
 }

titulo () {
 echo -e "\n  >  \e[7m$1\e[27m"
}

separador "USUARIOS"
echo -e "  >  Usuario actual:"  $(whoami)
echo -e "  >  Usuarios del Sistema -> " $(cat /etc/passwd | grep -i "sh$" | awk '{print $1}' FS=":" | xargs)

separador "BINARIOS"

titulo "SUIDS"
find / -perm /4000 2>/dev/null | grep -vE "kismet|snap|chrome|mount|chfn|chsh|passw|polkit"
titulo "Capabilities"
getcap -r / 2>/dev/null | grep "python|php|perl|ruby|node|gdb|vi" || echo "No hay capabilities"
titulo "SUDO NO PASSWD"
sudo -l | grep "NOPASSWD"

separador "ARCHIVOS"
titulo "Archvos de configuracion con permiso de escritura"
find /etc \-writable 2>/dev/null
find / -type f \-writable -name "*.conf" 2>/dev/null

titulo "Ruta: /tmp"
ls /tmp | grep -v "systemd"

titulo "Mails"
for mail in $(ls /var/mail); do echo "/var/mail/$mail"; done
titulo "WWW"
for varw in $(ls /var/www); do echo "/var/www/$varw"; done
titulo "Backups"
for back in $(ls /var/backups); do echo "/var/backups/$back"; done
find / -name "*.backup" 2>/dev/null
find / -name "*backup*" 2>/dev/null | grep ".gz$"
titulo "Archivos del usuario actual"
find / \-type f -user $(whoami) 2>/dev/null | grep -vE "firefox|cgroup|proc|run|go|.kube|.local|.config|.cache"

titulo "Logs"
find / -type f -name "*.log" -readable 2>/dev/null | grep -vE "metasploit|dkms"


separador "INFORMACION DEL SISTEMA"

echo -e "\n  > Sistema Operativo:" $(uname -a | awk '{print $1 " -> " $2 " -> " $3}' FS=' ')
echo -e "  > " $(lscpu | head -n3)
echo -e "  > " $(lscpu | grep -E "Virtualization | name")
echo -e "  > " $(lpstat -a 2>/dev/null || echo " No hay impresoras")

separador "PROGRMAS"
echo -e "\n  >  Binarios utiles?:" $(which nmap aws nc ncat netcat nc.traditional wget curl ping gcc g++ make gdb base64 socat python python2 python3 python2.7 python2.6 python3.6 python3.7 perl php ruby xterm doas sudo fetch docker lxc ctr runc rkt kubectl 2>/dev/null | awk '{print $4}' FS='/' | xargs)

separador "PROCESOS"
ps faux | grep -vE "firefox|VBox|]|libexec|systemd"
cat /etc/cron* /etc/at* /etc/anacrontab /var/spool/cron/crontabs/root 2>/dev/null | grep -v "^#"

separador "REDES"
echo -e "  >  Direcciones IP -> " $(hostname -I)
titulo "Puertos abiertos:"
netstat -tulvpn | grep -E "127.0.0|::" 2>/dev/null
titulo "Direcciones"
cat /etc/hosts 2>/dev/null | grep -vE "#|127.0|ff0|::" | sed '/^$/d'
titulo "Interfaces"
cat /etc/networks
arp -e || arp -a
titulo "Contenedores:"
route | grep "docker" | awk '{print $1" -> "$2" -> "$3 " -> " $8}' FS=" "

separador "PROTECCIONES"
echo -e "\n  >  SELinux?:" $(sestatus 2>/dev/null || echo "No hay \"sestatus\"")

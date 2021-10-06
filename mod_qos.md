**mod_qos** på Ubuntu 20.04 LTS

Opdater Ubuntu med:

```bash
apt update ; apt upgrade -y
apt install -y mlocate 
reboot
```

Installer et par pakker:

```bash
apt install -y apache2 apache2-dev libpcre3-dev libssl-dev

```

Hent sourcen fra https://sourceforge.net/projects/mod-qos/
```bash
wget https://netcologne.dl.sourceforge.net/project/mod-qos/mod_qos-11.68.tar.gz
tar -xf mod_qos-11.68.tar.gz
cd mod_qos-11.68/apache2
apxs -i -c mod_qos.c  -lcrypto -lpcre
```

Hvis alt er ok, så skal denne fil findes. Check!
```bash
ls -l /usr/lib/apache2/modules/mod_qos.so
```

Tid til at bygge mod_qos support værktøjer:
```bash
apt install -y libpng-dev
cd ../tools/
automake --add-missing
./configure
make
make install
```

Nu skal modulet enables:
```bash
echo "LoadModule qos_module /usr/lib/apache2/modules/mod_qos.so" > /etc/apache2/mods-available/qos.load
a2enmod qos
systemctl restart apache2
```

Modulet qos kan f.eks. konfigures på denne måde:
```bash
echo "<IfModule mod_qos.c>" > /etc/apache2/mods-available/qos.conf
echo "	QS_SRVMaxConnPerIP 20 100" >> /etc/apache2/mods-available/qos.conf
echo "</IfModule>" >> /etc/apache2/mods-available/qos.
```


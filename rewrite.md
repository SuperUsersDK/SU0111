```
<Directory "/var/www/html/download">
    RewriteEngine on
    RewriteCond %{REQUEST_FILENAME} !-f 
    RewriteRule ^(.+)$  /archive/$1     [L,R]
</Directory>
```

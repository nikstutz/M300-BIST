# Install and Configure PHPmyAdmin
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password test'
apt install phpmyadmin -y

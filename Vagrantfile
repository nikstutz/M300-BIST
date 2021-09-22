Vagrant.configure(2) do |config|


#---!Konfiguration Firewall!---
	config.vm.define "firewall" do |fw|
	fw.vm.box = "ubuntu/xenial64"
	fw.vm.provider "virtualbox" do |vb|
	vb.memory = "1024" 
	fw.vm.hostname = "firewall01"
	
	#IP Vergae und Port forwarding
		fw.vm.network "private_network", ip:"192.168.100.2" 
	end
	
	#Installation Firewall und Port freigabe
		fw.vm.synced_folder ".", "/var/www/html/", create: true
		fw.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		
		#schliessen aller Ports
		sudo ufw deny out to any
		
		#SSH Port öffnen
		sudo ufw allow 22
		
		#HTTP & HTTPS Ports öffnen
		sudo ufw allow 70
		sudo ufw allow 80
		sudo ufw allow 90
		sudo ufw allow 443
		sudo ufw -f enable 
      
      
		SHELL
	end

	# Aktivierung agent forwarding über SSH-Verbindungen
	config.ssh.forward_agent = true

	#Passwortvariablen 
	proxy_conf = "ProxyM300.conf"
	mysql_password = "rootmysql"
	
	
#---!Konfiguration Proxy!---
	config.vm.define "proxy" do |prx|
	prx.vm.box = "ubuntu/xenial64"
	prx.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"  
	prx.vm.hostname = "proxy01"
	
		#IP Vergabe und Port forwarding
		prx.vm.network "private_network", ip:"192.168.100.3"
	end
		#Installation der Dienste
		prx.vm.synced_folder ".", "/var/www/html/", create: true
		prx.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		
		#Installation und Konfiguration MySQL
		sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password #{mysql_password}"
		sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password #{mysql_password}"
		sudo apt-get -y install mysql-server
    
		# Proxy-Module aktivieren
		sudo a2enmod proxy
		sudo a2enmod proxy_html
		sudo a2enmod proxy_http
    
		# erreichbarer Port definieren
		echo "echo '<VirtualHost *:81>' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
	
		# Servername definieren
		echo "echo '	ServerName m300-mysql' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
		
		# Serveralias definieren
		echo "echo '	ServerAlias www.m300-mysql '>> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
		# schliessen der Konfig
		echo "echo '</VirtualHost>' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
		
		sudo a2ensite /etc/apache2/sites-available/#{proxy_conf}
    
		#Gruppenordner erstellen
		mkdir -p /grp/datenbank
		mkdir -p /grp/apache
    
		#Benutzer hinzufügen
		useradd dbroot -p password
		useradd webadmin -p password
    
		#Gruppe Hinzufügen
		groupadd datenbank
		groupadd apache
		
		#Benutzer der Gruppe hinzufügen
		usermod -aG datenbank dbroot
		usermod -aG apache webadmin
		
		#Gruppenorder Zugriff erstellen
		chmod 770 /grp/datenbank -R
		chown root:datenbank /grp/datenbank/ -R
		chmod 770 /grp/apache -R
		chown root:apache /grp/apache/ -R
		
		# LDAP-Module aktivieren
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo a2enmod cgi  
		sudo a2enmod ldap 
		sudo a2enmod authnz_ldap
		
		# LDAP Konfigurieren
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo a2enmod cgi  
		sudo a2enmod ldap 
		sudo a2enmod authnz_ldap
		sudo mkdir -p  /var/www/html/data && sudo chown www-data:www-data /var/www/html/data 
		export DEBIAN_FRONTEND=noninteractive
		
		# Setzen der Passwörter
		sudo debconf-set-selections <<<'slapd slapd/internal/generated_adminpw password admin'
		sudo debconf-set-selections <<<'slapd slapd/password2 password admin'
		sudo debconf-set-selections <<<'slapd slapd/internal/adminpw password admin'
		sudo debconf-set-selections <<<'slapd slapd/password1 password admin'
		sudo apt-get install -y slapd ldap-utils phpldapadmin
		sudo sed -i -e's/dc=example,dc=com/dc=nodomain/' /etc/phpldapadmin/config.php
      
		# LDAP-Module aktivieren
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo a2enmod cgi  
		sudo a2enmod ldap 
		sudo a2enmod authnz_ldap
		
		# LDAP Konfigurieren
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo a2enmod cgi  
		sudo a2enmod ldap 
		sudo a2enmod authnz_ldap
		sudo mkdir -p  /var/www/html/data && sudo chown www-data:www-data /var/www/html/data 
		export DEBIAN_FRONTEND=noninteractive
		
		# Setzen der Passwörter
		sudo debconf-set-selections <<<'slapd slapd/internal/generated_adminpw password admin'
		sudo debconf-set-selections <<<'slapd slapd/password2 password admin'
		sudo debconf-set-selections <<<'slapd slapd/internal/adminpw password admin'
		sudo debconf-set-selections <<<'slapd slapd/password1 password admin'
		sudo apt-get install -y slapd ldap-utils phpldapadmin
		sudo sed -i -e's/dc=example,dc=com/dc=nodomain/' /etc/phpldapadmin/config.php
	SHELL
end

#---!Konfiguration Webserver!---  
	config.vm.define "webserver" do |web|
	web.vm.box = "ubuntu/xenial64"
	web.vm.provider "virtualbox" do |vb|
	vb.memory = "512"  

	web.vm.hostname = "webserver01"
	
	#IP Vergabe und Port forwarding
		web.vm.network "private_network", ip:"192.168.100.4" 
		web.vm.network "forwarded_port", guest:80, host:8080, auto_correct: true  
	end

	#Installation und Konfiguration für Apache
		web.vm.synced_folder ".", "/var/www/html"
		web.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		sudo apt-get -y install debconf-utils apache2 nmap

		SHELL
	end

end
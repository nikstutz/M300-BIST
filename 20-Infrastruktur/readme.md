# Eigene Lernumgebung

# GitHub (K2)

Ich hatte bereit einen GitHub-Accounts erstellt. Deshalb musste ich diesen nicht mehr erstellen.

<img src="https://github.com/nikstutz/M300-BIST/blob/main/images/Bildschirmfoto5.png" alt="GitHub Profile" width="200px">

Danach habe ich die Repository erstellt.


# Benutzen des Git-CLI (K2)

Das GIT-CLI ist für das heruterladen von Projekten auf server unabdingbar, da man so einfach und sicher ganze Projekte auf einen Server bekommt ohne das man einen Client dazwischen schalten muss. ebenfalls beitet das CLI eine gute basis für automation, somit kann auch wenn eine neue Instanz erstellt wird direkt die aktuellste Version aus der repository pullen, auch wenn dies in den meisten Fällen nicht erwünschenswert ist.

<img src="https://github.com/nikstutz/M300-BIST/blob/main/images/Bildschirmfot65.png" alt="Git-CLI in use" width="400px">

# Vorhandene Vagrant Instanz (K2)

Um zu testen ob Virtualbox und Vagrant richtig installiert wurden, haben ich ein Vagrantfile heruntergeladen das zum Testen dient.

[In dem File](https://github.com/nikstutz/M300-BIST/blob/main/vagrant-files/Test-Vagrant/VAGRANT) steht folgendes (ohne Kommentare):

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y apache2 lynx
    ufw allow from 10.0.2.2 to any port 22
    ufw allow from 192.168.90.2 to any port 80
    ufw enable
  SHELL
end
```

Vagrant erstellt anhand von diesem File eine Virtuelle Maschiene und für die Commands aus die im Bereich ```config.vm.provision``` angegeben sind.

Installierte Programme:

* [lynx](https://lynx.browser.org/) | Command-Line Internet Browser
* [apache2](https://httpd.apache.org/) | Web-Server

Nachdem das File in einem eigenen Ordner angelegt wurde kann ich nach der Installation von Vagrant das Stup testen, in dem ich das erstellen der VM mit ```vagrant up --provider=virtualbox``` starte.

Sobald der Befehl fertig ist kann ich mit ```vagrant ssh``` auf die VM zugreifen.

Um zu testen ob der Web-Server richtig funktioniert, rufe ich mit ```lynx 127.0.0.1``` die lokale Website auf. Nun sollte ich in Textform die Standard-Website von Apache2 sehen. Falls ich hier eine Fehlermeldung bekomme, kann ich mit ```sudo service apache2 status``` überprüfen ob der Webserver läuft. Bei weiteren Problemen würde man dann auf die Logs zugreifen.

# Eigene Vagrant Services (K2)

## Proxy VM (K4)

Vagrant ist ein Tool zur Automtisierung für das Aufsetzen von VMs. So kann man zum Beispiel eine VM aufsetzen, auf der direkt Nginx / apache oder andere services installiert werden. Ein [Vagrantfile](https://github.com/nikstutz/M300-BIST/blob/main/vagrant-files/Reverse%20Proxy/Vagrantfile) sieht in etwa so aus:

```
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"

    config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "0.0.0.0"

    config.vm.network "private_network", ip: "192.168.150.3"

    config.vm.synced_folder "./nginx-config", "/etc/nginx"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
    end

    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        sudo a2enmod proxy
	sudo a2enmod proxy_html
	sudo a2enmod proxy_http
        ufw allow 22
        ufw allow 80
        ufw enable
    SHELL
end
```

Die Konfiguration kann nach veränderung mit ```vagrant reload --provision``` aktualisieren.

Auf dem Server ```10.1.31.7``` sind nun ein Reverse-Proxy Server installiert. Der Host-Port 8081 wird auf Port 81 des Reverse-Proxies weitergeleitet.

### Proxy konfiguration

Hier ist die Konfiguration des Proxy Servers:

```
	echo "echo '<VirtualHost *:80>' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
	echo "echo '	ServerName m300-mysql' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
	echo "echo '	ServerAlias www.m300-mysql '>> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
	echo "echo '</VirtualHost>' >> /etc/apache2/sites-available/#{proxy_conf}" | sudo bash
	sudo a2ensite /etc/apache2/sites-available/#{proxy_conf}
```

## Apache VM (K3)

Um den Reverse-Proxy richtig testen zu können habe ich noch einen Apache2 Server in einer anderen VM aufgesetzt.
Das [Vagrantfile](https://github.com/nikstutz/M300-BIST/blob/main/vagrant-files/WebHost/Vagrantfile) sieht folgendermassen aus (ohne Kommentare):

```
config.vm.define "webserver" do |web|
	web.vm.box = "ubuntu/xenial64"
	web.vm.provider "virtualbox" do |vb|
	vb.memory = "512"  

	web.vm.hostname = "webserver01"
	
		web.vm.network "private_network", ip:"192.168.10.150" 
		web.vm.network "forwarded_port", guest:70, host:7070, auto_correct: true  
	end

		web.vm.synced_folder ".", "/var/www/html"
		web.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		sudo apt-get -y install debconf-utils apache2 nmap

		SHELL
	end
```

Hier wird im Host-Only Netzwerk der Apache2 Webserver auf dem Host 192.168.90.3:80 freigegeben, auf welchen nur vom internen Netzwerk zugegriffen werden kann. In diesem internen Netzwerk ist ebenfalls ein Nginx Reverse-proxy, welcher über den Port 8080 exposed ist.

## Testfälle (K3)

Hier sind die Testfälle zum überprüfen der Funktionalität des Internen Netzwerks und des Reverse-Proxies aufgelistet und dokumentiert.

### Erlaubter Zugriff über Reverse-Proxy

| Erwartets Ergebnis | Eingetroffenes Ergebnis |
| ------------------ | ----------------------- |
| Verbindung erfolgreich | Verbindung erfolgreich |

Mit diesem Test soll überprüft werden ob der Reverse-Proxy korrekt eingerichtet ist und man wie darauf vorgesehen auch darauf zugreifen kann.

Im Browser kann man über die IP des Servers und den Port 8081 auf den Server zugreifen.

Falls man nun eine Apache2 Default seite sieht, ist man erfolgreich über den Nginx Proxy auf den Reverse-Proxy verbunden.

 Nr.| Beschreibung                                              | Kontrollie                                                                     | Soll-Situation      | Ist-Situation       | Bestanden? |
|:-:|-                                                          |-                                                                               |-                    |-                    |:-:         |
| 1 | `web` sollte anpingbar sein                               | ping 192.168.100.2                                                             | ping funktioniert   | ping funktioniert   | Y          |
| 2 | `web` sollte mit ssh darauf zugegriffen werden            | vagrant ssh webserver                                                          | Zugriff erfolgreich | Zugriff erfolgreich | Y          |
| 3 | `web` Apache Server funktioniert? via IP Zugriff          | http://192.168.100.3                                                           | Zugriff erfolgreich | Zugriff erfolgreich | Y          |
| 4 | `fw` Firewall regeln sind aktiv                           | "sudo ufw status "                                                             | korrekt Anzeigen    | Regeln richtig      | Y          |
| 5 | `prx` Zugriff SSH                                         | vagrant ssh reverse-proxserver                                                 | Zugriff erfolgreich | Zugriff erfolgreich | Y          |
| 6 | `prx` sollte anpingbar sein                               | ping 192.168.100.2                                                             | ping erfolgreich    | ping erfolgreich    | Y          |
| 7 | `prx` Die Gruppenordner wurden erstellt                   | "ll"                                                                           | Gruppen erstellt    | Gruppen erstellt    | Y          |
| 8 | `prx` MySQL funktioniert                                  |  sudo service mysql status                                                     | service läuft       | Service läuft       | Y          |


## Netzwerkplan
<img src="https://github.com/nikstutz/M300-BIST/blob/main/images/Netzwerk.png" alt="Netzwerkplan">

### Vagrant Befehle (K3)
| Vagrant Befehl| Funktionsbeschreibung |
| ------------- |-----------------------|
|      up       |  Startet die VM       |
|     halt      |  Schaltet die VM aus  |
|     init      |  Erstellt ein neues Vagrantfile |
|   Validate    |  Validiert das Vagrantfile |
|     ssh       |  Mit der VM per SSH verbinden |
|    reload     | Neustart der VM mit mit neuer Vagrantfile konfiguration |
|    suspend    |  haltet die VM        |
|    resume     | Startet eine gehaltene VM |
|    destroy    | Zerstört eine VM      |


### Benutzer und Rechtevergabe

Im Vagrantfile wurden die Gruppen erstellt:

![Gruppen erstellen](img/gruppen_erstellen.png)

Mit "vagrant ssh reverse-proxyserver" auf die VM zugreiffen.

Mit Befehl "ll" Gruppenordner anzeigen lassen:

![Gruppen anzeigen](img/gruppen_anzeigen.png)



## Apache Web-Server mit ngrok (K4) 

> Wichtig ist, dass Apache Web-Server bereits konfiguriert ist.

1. Entsprechende Datei bearbeiten:
```
sudo vi 000-default.conf
```

2. "VirtualHost" von "80" zu "8080" wechseln und speichern.

3. Mit folgendem Befehl wird ein direkter Tunnel durch die Firwall geöffnet. 
```
ngrok http 80
```

> Falls ngrok noch nicht installiert ist dann: [Ngrok installieren](https://snapcraft.io/install/ngrok/ubuntu)

4. Ich erlaube auf der Firewall allen IP's den Zugriff via SSH:
```
sudo ufw allow 22
```

5. Firewall Regel aktivieren:
```
 sudo ufw enable
```

6. Status überprüfen
```
 sudo ufw status
```


## Markdown editor (K2)

Ich habe mich beim editor für Visual Studio Code und die GitHub Weboberfläche entschieden.

VSCode benutzen ich da es eine Vielzahl an Erweiterungen gibt, welche mir auch ermöglichen im gleichen Editor z.B. Vagrant & Docker-Files zu bearbeiten.

Die Weboberfläche von GitHub wird auch zum schreiben der Markdown dokumentationen oder kurzen änderungen in allen Dateien verwendet, da dort dann auch alles direkt auf der remote ursprungs Repository verfügbar ist.

# SSH-Keys (K4)

## Wie funktioniert ein SSH-Key

SSH-Keys werden verwendet um die Verbindung zwischen einem SSH-Client und SSH-Server zusätzlich abzusichern oder um automatisierungsprozesse zu gewährleisten. Mit einem SSH-Key benötigten man nicht unbedingt ein Passwort um sich als Benutzer auf einem Server anzumelden, diese Option wird vorwiegend nur bei automatisierungen verwendet, dort aber auch oft durch andere Möglichkeiten ersetzt, da man nie gerne einen nicht passwortgeschützten Zugang zu einem Server hat. Die meisten Nutzer die einen SSH-Key verwenden, haben diesen ebenfalls Passwortgeschützt. Vorteil hierbei ist, dass man seinen Public-key auf alle Server hochladen kann, auf welche man Zugriff braucht und sich nun überall gesichert mit dem gleichen Passwort anmleden kann. Hierbei muss man beachten, dass das Passwort nicht für den Benutzer auf dem Server ist, das Passswort wird verwendet um den SSH-Key zu entschlüsseln. Der Key wiederum erlaubt es einem danach ohne Passwort bei einem Nutzer anzumelden.

## Wie Generiert man einen SSH-Key

### MacOS & Linux (Terminal)

Um einen SSH-Key auf MacOS oder Linux zu generieren, benötigt man das ssh-keygen tool, dieses sollte aber schon auf den meisten Distributionen vorinstalliert sein.

Mit folgendem Befehl startet man die generation eines SSH-Keypairs. Die Keygen-routine fragt nach allen erforderlichen angaben, wie zum Beispiel Speicherort und Passwort. Wenn man den SSH-Key nicht für automatisierung verwendet wird stark empfohlen ein Passwort einzurichten.

```ssh-keygen -t rsa```

### Windows

Um auf Windows einen SSH-Key zu generien gibt es verschiedene Möglichkeiten. Wenn man zum Beispiel git bash installiert hat, kann man den Key wie auf Linux erstellen. Eine andere Alternative ist, den Key von PuttyGen generiern zu lassen. [Putty](https://www.putty.org/) ist einer der beliebtesten SSH-Clients für Windows und liefert ein eigenes Programm zum generieren des SSH-Keys. Hierzu findet man hier eine gute [Anleitung](https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-windows).

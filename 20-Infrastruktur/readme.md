# Eigene Lernumgebung

# GitHub (K2)

Wir hatten alle schon GitHub-Accounts erstellt. Deshalb mussten wir diese nicht mehr erstellen.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-08-19%20um%2010.06.45.png" alt="GitHub Profile" width="200px">

Danach haben wir alle in die Repo eingeladen.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-08-19%20um%2011.38.53.png" alt="GitHub Collaborators" width="600px">

# Benutzen des Git-CLI (K2)

Das git-cli ist für das heruterladen von projekten auf server unabdingbar, da man so einfach und sicher ganze Projekte auf einen Server bekommt ohne das man einen Client dazwischen schalten muss. ebenfalls beitet das CLI eine gute basis für automation, somit kann auch wenn eine neue Instanz erstellt wird direkt die aktuellste Version aus der repo pullen, auch wenn dies in den meisten Fällen nicht erwünschenswert ist.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-08-19%20um%2011.44.38.png" alt="Git-CLI in use" width="400px">

# Vorhandene Vagrant Instanz (K2)

Um zu testen ob Virtualbox und Vagrant richtig installiert wurden, haben wir auf dem TBZ Cloud Server ein Vagrantfile heruntergeladen das zum Testen dient. Dieses ist im Verzeichnis ```~/VMs/VagrantTestVm``` des users ```ubuntu``` zu finden.

[In dem File](https://github.com/SayHeyD/M300-BIST/blob/master/vagrant-files/vagrant-test/Vagrantfile) steht folgendes (ohne Kommentare):

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

Nachdem das File in einem eigenen Ordner angelegt wurde können wir nach der Installation von Vagrant das Stup testen, in dem wir das erstellen der VM mit ```vagrant up --provider=virtualbox``` starten.

Sobald der Befehl fertig ist können wir mit ```vagrant ssh``` auf die VM zugreifen.

Um zu testen ob der Web-Server richtig funktioniert, rufen wir mit ```lynx 127.0.0.1``` die lokale Website auf. Nun sollten wir in Textform die Standard-Website von Apache2 sehen. Falls wir hier eine Fehlermeldung bekommen, können wir mit ```sudo service apache2 status``` überprüfen ob der Webserver läuft. Bei weiteren Problemen würde man dann auf die Logs zugreifen.

# Eigene Vagrant Services (K2)

## Nginx VM (K4)

Vagrant ist ein Tool zur Automtisierung für das Aufsetzen von VMs. So kann man zum Beispiel eine VM aufsetzen, auf der direkt Nginx / apache oder andere services installiert werden. Ein [Vagrantfile](https://github.com/SayHeyD/M300-BIST/blob/master/vagrant-files/nginx-reverse-proxy/Vagrantfile) sieht in etwa so aus:

```
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"

    config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "0.0.0.0"

    config.vm.network "private_network", ip: "192.168.90.2"

    config.vm.synced_folder "./nginx-config", "/etc/nginx"

    config.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
    end

    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y nginx
        service nginx restart
        ufw allow from 10.0.2.2 to any port 22
        ufw allow 80
        ufw enable
    SHELL
end
```

Dieses File setzt einen [Nginx](https://www.nginx.com/) Reverse-Proxy auf und verbindet den lokalen ordner "./nginx-config" mit den ordner "./etc/nginx" auf der VM. Somit kann man die konfiguration von nginx bearbeiten uach wenn die VM schon läuft. Die Konfiguration kann nach veränderung mit ```vagrant reload --provision``` aktualisieren.

Auf dem Server ```10.1.31.7``` sind nun ein Nginx Reverse-Proxy und ein Apache Server installiert. Der Host-Port 8080 wird auf Port 80 des Reverse-Proxies weitergeleitet. Ansonsten sind die Nginx und Apache VMs in ihrem eigenen virtuellen Netzwerk.

### Nginx konfiguration

Hier ist die Konfiguration des Nginx Servers:

```
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	location / {
		proxy_pass http://192.168.90.3/$uri;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
}
```

## Apache VM (K3)

Um den Reverse-Proxy richtig testen zu können haben wir noch einen Apache2 Server in einer anderen VM aufgesetzt.
Das [Vagrantfile](https://github.com/SayHeyD/M300-BIST/blob/master/vagrant-files/apache2-web/Vagrantfile) sieht folgendermassen aus (ohne Kommentare):

```
Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/bionic64"
  
    config.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"
  
    config.vm.network "private_network", ip: "192.168.90.3"
  
    config.vm.synced_folder "./web-root", "/var/www"
    config.vm.synced_folder "./apache2-config", "/etc/apache2"
  
    config.vm.provider "virtualbox" do |vb|
       vb.memory = "512"
    end

    config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y apache2 lynx
        ufw allow from 10.0.2.2 to any port 22
        ufw allow from 192.168.90.2 to any port 80
        ufw enable
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

Hierzu verbindet man sich zuerst per Wireguard.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-09-02%20um%2009.44.44.png" alt="WireGuard Menu" width="200px">

Danach kann man im Browser über die IP des Servers un den Port 8080 auf den Server zugreifen.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-09-02%20um%2009.47.09.png" alt="WebContent" width="600px">

Falls man nun eine Apache2 Default seite sieht, ist man erfolgreich über den Nginx Proxy auf den Reverse-Proxy verbunden.

### Unerlaubter Direkter Zugriff auf VM

| Erwartets Ergebnis | Eingetroffenes Ergebnis |
| ------------------ | ----------------------- |
| Timeout | Timeout |

Um zu testen ob man über den VM-Host (TBZ Cloud-Server) direkt auf den WEbserver zugreifen kann isntallieren wir das Programm [lynx](https://lynx.browser.org/). Lynx ist ein CLI Webbrowser für linux. Wenn wir per SSH auf den TBZ Cloud-Server verbunden sind können wir lynx installieren.

```sudo apt install -y lynx```

Nach der Installation von lynx könen wir versuchen auf die Website der VM zuzugrifen.

Der Command um sich mit der Website zu verbinden: ```lynx 192.168.90.3```

Nachdem wir den Befehl eingegeben haben können wir mit Enter bestätigen und danach sollten wir folgendes in der Konsole sehen.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-09-02%20um%2010.38.10.png" alt="GitHub Collaborators" width="600px">

Daher Lynx keine Fehlermeldung für Timeouts ausgibt, nehmen wir nach 15 sekunden in dieser Ansicht an, dass die Website nicht direkt erreichbar ist.

## Host-Only Netzwerk

| Bezeichnung | Daten |
|-------------|-------|
| Netz-ID | 192.168.90.0 |
| Subnet | 255.255.255.0 |
| Nginx | 192.168.90.2 |
| Apache | 192.168.90.3 |

In dem Netzwerk ist DHCP deaktiviert und die Adressen sind statisch vergeben.

## Netzwerkplan
<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/netzwerkplan.png" alt="Netzwerkplan">

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


## Apache Web-Server mit ngrok (K4)

1. Wir befinden uns via ssh auf dem TBZ Cloud Server "10.1.31.20" und navigieren in folgendes Verzeichnis:
```
/etc/apache2/sites-available
```
> Wichtig ist, dass Apache Web-Server bereits konfiguriert ist. Anleitung [Apache Web-Server](https://github.com/SayHeyD/M300-BIST/tree/master/20-Infrastruktur#apache-vm-k3)

2. Entsprechende Datei bearbeiten:
```
sudo vi 000-default.conf
```

3. "VirtualHost" von "80" zu "8080" wechseln und speichern.

4. Mit folgendem Befehl wird ein direkter Tunnel durch die Firwall geöffnet. 
```
ngrok http 80
```

> Falls ngrok noch nicht installiert ist dann: [Ngrok installieren](https://snapcraft.io/install/ngrok/ubuntu)

Um zu verhindern, dass jeder mit SSH verbinden können, geben wir den Zugriff für bestimmte IP's frei

5. Wir erlauben auf der Firewall gewissen IP's den Zugriff via SSH:
```
sudo ufw allow from 10.1.31.50 to any port 22
```

6. Firewall Regel aktivieren:
```
 sudo ufw enable
```

7. Status überprüfen
```
 sudo ufw status
```


## Markdown editor (K2)

Wir haben uns beim Markdown editor für Visual Studio Code und die GitHub Weboberfläche entschieden.

VSCode benutzen wir da es eine Vielzahl an Erweiterungen gibt, welche uns auch ermöglichen im gelichen Editor z.B. Vagrant & Docker-Files zu bearbeiten.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-08-19%20um%2018.09.04.png" alt="VSCode split window" width="600px">

Die Weboberfläche von GitHub wird auch zum schreiben der Markdown dokumentationen oder kurzen änderungen in allen Dateien verwendet, da dort dann auch alles direkt auf der remote origin repo verfügbar ist.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-08-19%20um%2018.17.36.png" alt="GitHub Editor" width="600px">

# SSH-Keys (K4)

## Wie funktioniert ein SSH-Key

SSH-Keys werden verwendet um die Verbindung zwischen einem SSH-Client und SSH-Server zusätzlich abzusichern oder um automatisierungsprozesse zu gewährleisten. Mit einem SSH-Key benötigten man nicht unbedingt ein Passwort um sich als Benutzer auf einem Server anzumelden, diese Option wird vorwiegend nur bei automatisierungen verwendet, dort aber auch oft durch andere Möglichkeiten ersetzt, da man nie gerne einen nicht passwortgeschützten Zugang zu einem Server hat. Die meisten Nutzer die einen SSH-Key verwenden, haben diesen ebenfalls Passwortgeschützt. Vorteil hierbei ist, dass man seinen Public-key auf alle Server hochladen kann, auf welche man Zugriff braucht und sich nun überall gesichert mit dem gleichen Passwort anmleden kann. Hierbei muss man beachten, dass das Passwort nicht für den Benutzer auf dem Server ist, das Passswort wird verwendet um den SSH-Key zu entschlüsseln. Der Key wiederum erlaubt es einem danach ohne Passwort bei einem Nutzer anzumelden.

## Wie Generiert man einen SSH-Key

### MacOS & Linux (Terminal)

Um einen SSH-Key auf MacOS oder Linux zu generieren, benötigt man das ssh-keygen tool, dieses sollte aber schon auf den meisten Distributionen vorinstalliert sein.

Mit folgendem Befehl startet man die generation eines SSH-Keypairs. Die Keygen-routine fragt nach allen erforderlichen angaben, wie zum Beispiel Speicherort und Passwort. Wenn man den SSH-Key nicht für automatisierung verwendet wird stark empfohlen ein Passwort einzurichten.

```ssh-keygen -t rsa```

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-09-02%20um%2008.31.29.png" alt="SSH-Keygen generation" width="600px">

### Windows

Um auf Windows einen SSH-Key zu generien gibt es verschiedene Möglichkeiten. Wenn man zum Beispiel git bash installiert hat, kann man den Key wie auf Linux erstellen. Eine andere Alternative ist, den Key von PuttyGen generiern zu lassen. [Putty](https://www.putty.org/) ist einer der beliebtesten SSH-Clients für Windows und liefert ein eigenes Programm zum generieren des SSH-Keys. Hierzu findet man hier eine gute [Anleitung](https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-windows).

# Container

## Docker-Befehle
Die Verwendung von docker besteht darin, eine Kette von Optionen und Befehlen zu übergeben, gefolgt von Argumenten. Die Syntax übernimmt diese Form:
```
$ docker [option] [command] [arguments]
```
Um alle verfügbaren Unterbefehle zu sehen, gibt man folgendes ein:
```
$ docker
```

|Befehl          |Bedeutung
|:---------------|:---------------------------------------------------------------|
|attach            |Attach local standard input, output, and error streams to a running container|
|build             |Build an image from a Dockerfile|
|commit            |Create a new image from a container's changes|
cp                |Copy files/folders between a container and the local filesystem
create            |Create a new container
diff              |Inspect changes to files or directories on a container's filesystem
events            |Get real time events from the server
exec              |Run a command in a running container
export            |Export a container's filesystem as a tar archive
history           |Show the history of an image
images            ||List images
import            |Import the contents from a tarball to create a filesystem image
info              |Display system-wide information
inspect           |Return low-level information on Docker objects
kill              |Kill one or more running containers
load              |Load an image from a tar archive or STDIN
login             |Log in to a Docker registry
logout            |Log out from a Docker registry
logs              |Fetch the logs of a container
pause             |Pause all processes within one or more containers
port              |List port mappings or a specific mapping for the container
ps                |List containers
pull              |Pull an image or a repository from a registry
push              |Push an image or a repository to a registry
rename            |Rename a container
restart           |Restart one or more containers
rm                |Remove one or more containers
rmi               |Remove one or more images
run               |Run a command in a new container
save              |Save one or more images to a tar archive (streamed to STDOUT by default)
search            |Search the Docker Hub for images
start             |Start one or more stopped containers
stats             |Display a live stream of container(s) resource usage statistics
stop              |Stop one or more running containers
tag               |Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
top               |Display the running processes of a container
unpause           |Unpause all processes within one or more containers
update            |Update configuration of one or more containers
version           |Show the Docker version information
wait              |Block until one or more containers stop, then print their exit codes

## Weitere Befehle
### Alle Images entfernen
```
$ docker rmi $(docker images -a -q)
$ docker rm $(docker ps -a -f status=exited -q)

## Docker Installation

Um Docker auf Ubuntu zu installieren gibt es eine Anleitung von [Docker](https://docs.docker.com/engine/install/ubuntu/) selbst.

Um Docker zu installieren führt man die folgende Befehle aus:

sudo apt install docker-ce (Normale installation)           
sudo apt-get install docker-compose -y (Installation von Docker-Compose)

Um die Container automatisch bei einer VM-Neuinstallation auf das Gastsystem zu laden wird unser Github Repository auf System geladen. Dies geschieht mit folgendem Befehl:

sudo git clone https://github.com/nikstutz/M300-BIST.git
cd M300-BIST/30-Container/Docker-files/

## Docker

### MySQL Container mit Docker

#### Schritt 1: Dockerfile

Um MySQL mit all den benötigten Inhalten überhaupt installieren zu können, brauchen wir das Dockerfile welches das System vorbereitet mithilfe von z.B. Updates und die Installationsbefehle beschreibt. Folgender Code übernimmt diesesn Teil:

FROM ubuntu:latest

RUN apt-get update -y && \
    apt-get autoremove -y && \
    apt-get install --no-install-recommends lsb-release && \
    tar -xvf archive.tar.gz &&\
    rm -rf /var/lib/apt/lists/* && \
    rm -rf archive.tar.gz

ADD ./apache-setup.sh /tmp/apache-setup.sh
RUN /bin/sh /tmp/apache-setup.sh

ADD ./mysql-setup.sh /tmp/mysql-setup.sh
RUN /bin/sh /tmp/mysql-setup.sh

ADD ./phpmyadmin-setup.sh /tmp/phpmyadmin-setup.sh
RUN /bin/sh /tmp/phpmyadmin-setup.sh
# Adding this will expose mysql on a random host port. It's recommended to avoid this. Other containers on the same 
# host can use the service without it.
#EXPOSE 3306

CMD ["/usr/sbin/mysqld"]

#### Schritt 2: Setups
Damit unsere Installationen auch funktionieren und konfiguriert werden können, brauchen wir noch ein Setup der Komponenten. 
Da es sich bei MySql nicht nur um den Dienst SQL handelts sondern noch Apache und PhpMyAdmin, müssen wir diese auch konfigurieren.

##### Apache

apt update
apt install apache2 -y -q
ufw allow 'Apache'
systemctl enable apache2
systemctl start apache2
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

##### MySQL
#!/bin/sh

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

apt-get update && apt-get install -y mysql-server && apt-get clean && rm -rf /var/lib/apt/lists/*

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

/usr/sbin/mysqld &
sleep 5
echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'mysql-server' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

##### PhpMyAdmin# Install and Configure PHPmyAdmin
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password test'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password test'
apt install phpmyadmin -y

#### Ausführung / Container erstellung
Die Repository wurde bei erstellung der VM bereits beigefügt. 
Nun muss nurnoch der Container erstellt und ausgeführt werde.

Zur erstellung des Containers nutzen wir folgenden Code:
docker build -t MySQL:1.0 .

Um das ganze auszuführen kommt folgender Code ins Spiel:
docker run -p 0.0.0.0:80 -t MySQL:1.0

```

### Starten eines Containers

Um einen einfachen Container zu starten können wir einfach den befehl ```docker run -p 0.0.0.0:80:80 -d nginx``` ausführen.

Dieser Befehl startet einen nginx container mit standard-konfiguration. Der Port 80 des Containers wird auf den Port 80 des Hosts gebunden und Exposed. Ebenso wird der Container als deamon gestartet.

Nun shen wir uns an welcher Teil des commands was genau macht.

```docker run``` sagt Docker das wir einen Container starten wollen und jetzt die Optionen für den Start folgen.

```-p 0.0.0.0:80:80``` sagt Docker das der Host Port ```0.0.0.0:80``` auf den Container Port ```80``` gebunden wird. Das bedeutet das alles was im Container auf den Port 80 läuft auch auf den Host-Port ```0.0.0.0:80``` läuft. Der Syntax für das Port-Binding funktioniert also folgendermassen: ```-p [HostIP mit Port]:[Container Port]```

```-d``` sagt docker das man den Container als deamon starten will. Das bededutet das der Server als Dienst läuft und das man nach dem Start die Console-Session normal weiter benutzen kann. Wenn man den Container nicht als Deamon startet kann man die Konsole nicht weiterverwenden bis man den Container wieder mit ```Ctrl+C```beendet.

Nun haben wird einen  Docker Container gestartet und können auf die Website über die Host-IP zugreifen.
Es gibt natürlich noch viele weitere möglichkeiten einen Container zu starten.

### Docker Netzwerk

Um uns die verfügbaren Docker Netzwerke anzeigen zu lassen, können wir den Befehl ```docker network ls``` ausführen. Dieser Befehl zeigt uns alle verfügbaren Netzwerke an.

Docker bietet verschiedene Netzwerktypen an, die man von der virtualisierung her auch kennt. Darunter fallen z.B. Bridged oder Host-Only netzwerke.


Um ein neues Bridged netzwerk zu erstellen führen wir folgenden command aus:
```docker network create test```

Neu erstellte Docker Netzwerke sind standardmässig Bridged Netzwerke.
Nun sollte unser Netzwerk auch unter ```docker network ls``` aufgeführt werden.


### Nginx Reverse-Proxy

Der Reverse-proxy soll die Verbindung von web-app container zum internet herstellen. somit ist der web-app container nicht direkt mit dem WAN verbunden um somit noch etwas mehr abgeschützt.

Der reverse-proxy Container muss folgende Eigenschaften aufweisen:

* Auf Port 80 von aussen erreichbar sein
* Mit dem phone-book-app eine verbindung als reverse-proxy herstellen können

Hierfür haben wir uns entschieden in einem nginx manuell zu installieren.

Als erstes müssen wir eine reverse-proxy konfiguration anlegen. Diese wird beim builden zur Datei /etc/nginx/sites-available/default kopiert.

Danach haben wir noch ein [setup.sh](https://github.com/nikstutz/M300-BIST/blob/ea80fb4df87be10551500a662c6030d1a85ea33a/30-Container/Docker-files/reverse-proxy/setup.sh) script angelegt um nach dem starten des containers den nginx service zu starten.

Nun können wir das image mit dem command ```docker build -t reverse-proxy .``` builden.
Nun können wir das image wie gewohnt mit ```docker run reverse-proxy``` starten.

## Testen eines Docker Services (K3)

Um einen Docker Service zu testen gibt es mehrere Möglichkeiten. Die beste möglichkeit um die Funktionalität eines COntainers zu überprüfen sind die Logs von Docker.

Die Logs können mit dem Command ```docker logs [Container ID / Container Name]``` abgrufen werden und werden bei laufenden Containern fortlaufend aktualisert und können erneut abgerufen werden.

Bei laufenden Contaiern können wir sogar in die shell des Containers zugreifen. Dies geht mit dem Befehl ```docker exec -it [Container ID / Conatiner Name] bash``` somit könenn wir sogar befehle im Container ausführen und sehen was noch gemacht werden muss um den Container korrekt zum laufen zu bringen.

### Testfälle (K3)

#### Testen einer Verbindung zum Docker Service

Aufgabe: Verbindung per Web-browser aufbauen.
Erwartetes Ergebnis: Verbindung zur Website kann aufgebaut werden.

Als erstes veruschen ich auf die [Website](http://192.168.100.11/) (IP der VM) zuzugreifen. Hier wird die Defaultseite erfolgreich geladen. Mit dem Datenbankname angefügt an dem Link, gelangen wir zu unserer Datenbank

Mit diesem Test haben wir folgendes getestet:

* Korrekte Funktion des Reverse-Proxies
* Korrekte Funktion der Datenbank
* Korrekte Verbindung der Container

#### Überprüfen der Logs des Web-Apps

Aufgabe: Überprüfen der Logs des Web Containers und auf Fehler überprüfen
Erwartetes Ergebnis: Keine Fehler ausser HTTP Fehlercodes werden in den Logs angezeigt.

Wir verbinden uns mit dem Server und holen uns die ID oder den Namen des Web containers.
Dies machen wir mit dem Befehl ```docker ps```. Der aktuelle Name des Containers ist apache. Nun können wir uns die Logs mit ```docker logs apache``` anzeigen lassen.

Die logs des Containers zeigen uns nun folgendes an:

```
Restarting nginx: nginx.
Application key set successfully.
Nothing to migrate.
[06-Oct-2020 14:22:38] NOTICE: fpm is running, pid 38
[06-Oct-2020 14:22:38] NOTICE: ready to handle connections
127.0.0.1 -  06/Oct/2021:14:49:18 +0000 "GET /index.php" 200
127.0.0.1 -  06/Oct/2021:14:49:21 +0000 "GET /index.php" 200
127.0.0.1 -  06/Oct/2021:14:47:27 +0000 "GET /index.php" 200
127.0.0.1 -  06/Oct/2021:14:50:17 +0000 "GET /index.php" 302
127.0.0.1 -  06/Oct/2021:14:50:18 +0000 "GET /index.php" 200
127.0.0.1 -  06/Oct/2021:14:54:20 +0000 "GET /index.php" 404
```

Die erste Zeile zeigt uns das Nginx neugestartet wird.
Danach kommen 2 Meldungen , welche auch keine Fehlermeldungen ausgeben und somit sind diese auch OK.
Die nächsten Zeilen, zeigen uns die Aktivität vom apache Server und hier sehen wir das erste mal einen Fehlercode. Den HTTP Fehlercode 404. Dies ist aber nicht weiter schlimm, da dieser nur anzeigt das eine Seite nicht gefunden werden konnte.

## Image Bereitstellung (K6)

Die einfachste Methode um images bereitzustellen ist Docker Hub. Docker Hub bietet einem die möglichkeit direkt über das docker-cli seine images von einem Server auf den Docker-Hub hochzuladen.

Da Docker-Hub vorher noch nicht bekannt war, habe ich mich der Github Methode gewidmet welche eigentlich auch relativ Simpel ist. Dort erstellt man eine Repository mit den Dockerfiles. Wenn man auf einem Gastsystem nun die Container einbinden möchte, Klont man sich die Repository simpel auf den eigenen Rechner. Von dort aus kann dann mit den dockerfiles gearbeitet werden.

## Persönlicher Wissensstand

Bisher waren mir "Container" oder "Docker" nicht wirklich ein Begriff. In meiner Arbeitsumgebung hatte ich nur mit gewöhnlichen VM's zu tun, welche mit VMWare Player oder Virtualbox erstellt wurden.
Die Möglichkeiten und die Vielzahl an Verwendungszewecken, welche mit Containersystemen bewerkstelligt werden können, sind mir bisher nicht bekannt gewesen.

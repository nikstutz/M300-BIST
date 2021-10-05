# Container

## Docker Installation

Um Docker auf Ubuntu zu installieren gibt es eine Anleitung von [Docker](https://docs.docker.com/engine/install/ubuntu/) selbst.

Um Docker neu zu installieren führt man die folgende Befehle aus:

Update der repositories: ```sudo apt-get update```

Zusätzlich benötigte programme installieren:
```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

Docker GPG Key hinzufügen:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Um den Key zu überprüfen: ```sudo apt-key fingerprint 0EBFCD88```

Der Key sollte folgendes Ausgeben:
```
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

Nun kann man die DOcker repository hinzufügen:
```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Danach kann man docker über apt-get isntallieren:
```sudo apt-get update```  
```sudo apt-get install docker-ce docker-ce-cli containerd.io```

Nun sollte man mit dem Befehl ```docker -v``` die aktuelle installierte Dockerversion sehen.

## Docker

### MySQL Container mit Docker

#### Schritt 1: MySQL Docker Image laden

1. Ziehe ein mysql-Image mit der aktuellsten Version. Es können auch ältere Versionen ausgewählt werden, wenn ```latest``` durch die entsprechende Version ersetzt wird. Eine Übersicht der Versionen sind auf [dieser Seite](https://hub.docker.com/_/mysql)

```bash
docker pull mysql/mysql-server:latest
```

2. Überprüfen, ob das Images erfolgreich heruntergeladen wurde.

```bash
docker images
```

#### Schritt 2: MySQL Container deployen

1. Nun wird ein container erzeugt. ```[container_name]``` muss durch einen gewünschten Namen ersetzt werden. Die Option ```-d``` weist Docker an, den Container als Dienst im Hintergrund laufen zu lassen. Es kann wieder eine andere Version ausgewählt werden, indem ```latest``` durch die entsprechende Versions-Nummer ersetzt wird.

```bash
docker run --name=[container_name] -d mysql/mysql-server:latest
```

2. Überprüfen, ob der MySQL Container gestartet ist.

```bash
docker ps
```

#### Schritt 3: Mit MySQL Docker Container verbinden


1. Zuerst muss MySQL client package installiert werden.

```bash
apt-get install mysql-client
```

2. Dann den MySQL client im Container starten.

```bash
docker exec -it [container_name] mysql -uroot -p
```
![rootpw](https://github.com/SayHeyD/M300-BIST/blob/master/images/tempsnip.png)

3. Das root-Passwort angeben.

4. Zum Schluss das root-Passwort ändern. ```[newpassword]``` durch das neue Passwort ersetzen.

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '[newpassword]';
```

#### Schritt 4: MySQL Container konfigurieren (K3)

Info: Die Konfigurations-Optionen finden sich unter folgenden Pfad:  ```/etc/mysql/my.cnf```.

1. Zuerst ein neuer Pfad für den Container erstellen.

```bash
mkdir -p /root/docker/[container_name]/conf.d
```

2. Wenn in diesem Verzeichnis Änderungen gemacht wurden, ist es notwendig, den Container zu entfernen und einen neuen zu erstellen. Der neue Container bezieht die konfig-Datei, welche vorher erstellt wurde.

Dazu muss der Container gestartet werden und den volumepfad mit folgenden befehlen gebildet werden.

```bash
docker run \
--detach \
--name=[container_name]\
--env="MYSQL_ROOT_PASSWORD=[my_password]" \
--publish 6603:3306 \
--volume=/root/docker/[container_name]/conf.d:/etc/mysql/conf.d \
mysql
```

3. Um zu überprüfen, ob der Container die Konfig-Datei vom Host ladet, folgenden Befehl ausführen.

```bash
mysql -uroot -pmypassword -h127.0.0.1 -P6603 -e 'show global variables like "max_connections"';
```

### Starten eines Nginx Containers

Um einen einfachen Container zu starten können wir einfach den befehl ```docker run -p 0.0.0.0:80:80 -d nginx``` ausführen.

Dieser Befehl startet einen nginx container mit standard-konfiguration. Der Port 80 des Containers wird auf den Port 80 des Hosts gebunden und Exposed. Ebenso wird der Container als deamon gestartet.

Nun shen wir uns an welcher Teil des commands was genau macht.

```docker run``` sagt Docker das wir einen Container starten wollen und jetzt die Optionen für den Start folgen.

```-p 0.0.0.0:80:80``` sagt Docker das der Host Port ```0.0.0.0:80``` auf den Container Port ```80``` gebunden wird. Das bedeutet das alles was im Container auf den Port 80 läuft auch auf den Host-Port ```0.0.0.0:80``` läuft. Der Syntax für das Port-Binding funktioniert also folgendermassen: ```-p [HostIP mit Port]:[Container Port]```

```-d``` sagt docker das man den Container als deamon starten will. Das bededutet das der Server als Dienst läuft und das man nach dem Start die Console-Session normal weiter benutzen kann. Wenn man den Container nicht als Deamon startet kann man die Konsole nicht weiterverwenden bis man den Container wieder mit ```Ctrl+C```beendet.

Nun haben wird einen Nginx Docker Container gestartet und können auf die Website über die Host-IP zugreifen.
Es gibt natürlich noch viele weitere möglichkeiten einen Container zu starten.

### Docker-Commands (K3)

| Docker Befehl| Funktionsbeschreibung |
| ------------- |-----------------------|
| docker run | Container starten |
| docker ps  | Aktive Container anzeigen |
| docker stop  | Einen oder mehrere Container stoppen  |
| docker restart  | Einen oder mehrere Container neustarten|
| docker rm | Einen oder mehrere Container löschen|
| docker inspect | Speicherort des Volumes überprüfen |

#### docker run

```docker run [OPTIONS] IMAGE [COMMAND] [ARG...]``` startet den spezifizierten Container mit den spezifizierten Konfigurationsmöglichkeiten.

Mögliche Argumente.

| Option | Beschreibung |
| ----- | ----- |
| -d | Startet den Container als deamon |
| -p [HostIP mit Port]:[Container Port] | Exposed und Bindet den COntainer Port auf den Host-Port |
| --hostname [Hostname] oder -h [Hostname] | Setzt den Hostname des Containers |

[Zur offiziellen Dokumentation](https://docs.docker.com/engine/reference/commandline/run/)

#### docker ps

```docker ps [OPTIONS]``` listet Container auf. Ohne angegebene Optionen listet der COmmand alle laufenden Container auf.

| Option | Beschreibung |
| ----- | ----- |
| -a | Listet alle Contaienr auf die laufen und gelaufen sind |
| -s | Zeigt die Festplattenbelegung pro Container an |
| --format "[Format String]" | Formatiert den Output des Befehls. Die Keys zur Formatierung können [hier eingesehen werden](https://docs.docker.com/engine/reference/commandline/ps/#formatting) |

[Zur offiziellen Dokumentation](https://docs.docker.com/engine/reference/commandline/ps/)

## Container für Eigenen Service (K3)

Als Vorbereitung für unseren eigenen Service müssen wir einige Container erstellen.

User Service soll eine eigens für dieses Modul erstellte Web-App sein. Die Webapp wurde mit [Laravel](https://laravel.com/) erstellt. Laravel ist ein PHP-Framework. Unsere Web-App ist ein kleines Telefonbuch in dem wir KOntakte speichern können. Damit alles richtig funktioniert, brauchen wir einen Nginx-Webserver auf welchem unsere Apllikationsdateien liegen, einen MySQL-Datenbank Server auf welchem usnere Daten liegen und einen Reverse-Proxy.

Da wir für Laravel php commands im container ausführen müssen, können wir den php-fpm server nicht vom webserver trennen und deshalb sind beide Services im gleichen Container.

Benötigte Container:
* nginx / php-fpm webserver mit applikationsdateien
* mysql datenbankserver
* ngninx reverse-proxy

Ebenfalls benötigen wir ein eigens Netzwerk um unseren Service in Docker das erste mal zu testen, bevor wir das ganze auf Kubernetes übernehmen.

### Docker Netzwerk

Um uns die verfügbaren Docker Netzwerke anzeigen zu lassen, können wir den Befehl ```docker network ls``` ausführen. Dieser Befehl zeigt uns alle verfügbaren Netzwerke an.

Docker bietet verschiedene Netzwerktypen an, die man von der virtualisierung her auch kennt. Darunter fallen z.B. Bridged oder Host-Only netzwerke.

Für usnere Zwecke wollen wir ein eigenes bridged Netzwerk erstellen, damit sich unsere container per name und nicht nur per IP resolven können.

Um ein neues Bridged netzwerk zu erstellen führen wir folgenden command aus:
```docker network create phone-book```

Neu erstellte Docker Netzwerke sind standardmässig Beidged Netzwerke.
Nun sollte unser Netzwerk auch unter ```docker network ls``` aufgeführt werden.

### MySQL Server

Das [MySQL-Server iamge](https://hub.docker.com/_/mysql), das von mysql selbst gegeben wird, muss nur noch konfiguriert werdne um gestartet werden zu können, hier müssen wir kein eigens Dockerfile anlegen. Um das ganze erst einmal zu testen, können wir einen MySQL-Server Container mit dem folgenden Command starten.

Damit das ganze korrekt funktioniert, empfehlen wir ein eigens Verzeichnis für den MySQL container zu erstellen, und in diesem Verzeichnis einen ordner data zu erstellen. Danach können wir den Command ausführen und die ganzen MySLQ Daten werden dank der ```--mount``` option in das data verzeichnis geschrieben und sind somit persistent (Auch nach neustart des Containers verfügbar).

```docker run --name=mysql-server -p 127.0.0.1:6033:3306 --env="MYSQL_ROOT_PASSWORD=root_password" --env="MYSQL_USER=phone-book" --env="MYSQL_PASSWORD=password" --env="MYSQL_DATABASE=phone-book" --mount type=bind,source="$(pwd)"/data,target=/var/lib/mysql -d mysql:5.7```

Danach können wir auf dem Host versuchen uns mit dem mysql server zu verbinden: ```mysql -h 127.0.0.1 -P 6033 -uphone-book -p``` falls wir eine erfolgreiche Verbindung herstellen konnten hat alles geklappt.

### Nginx / Php-fpm Webserver mit Applikationsdateien

Für den php7.4-fpm server gitb es bereits ein [docker-image](https://hub.docker.com/_/php), jedoch sind dort noch nicht alle php-extensions installiert welche wir für das betreiben der Web-App benötigen. Man könnte diese extensions in einem [Dockerfile](https://github.com/SayHeyD/M300-BIST/blob/master/docker-files/php-fpm/Dockerfile) alle manuell installieren, allerdings gibt es bereits ein script welches einen grossteil der Installation für einen übernimmt, wir müssen zwar immer noch ein eigenes im [Dockerfile](https://github.com/SayHeyD/M300-BIST/blob/master/docker-files/php-fpm/Dockerfile) hinzufügen um den Container zu erstellen, jedoch geht das mit dem [```install-php-extensions``` script](https://github.com/mlocati/docker-php-extension-installer) einiges schneller.

Nun müssen wir noch den nginx server und composer installieren dies machen wir im [Dockerfile](https://github.com/SayHeyD/M300-BIST/blob/master/docker-files/php-fpm/Dockerfile) einfach mit apt-get und bei composer mit curl. Daher wir curl schon mit den php-extensions mitinstallieren haben, müssen wir dies hier nicht mehr tun. Ebenfalls benötigen wir git für die dependecies.

Nginx & git installation: ```RUN apt-get install nginx git -y```
Composer installation: ```curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer```

Bevor wir den Webserver-Container builden können, müssen wir erst das Laravel-Projekt vorbereiten.
Hierfür kopieren wir im Verzeichnis vor den builden die ```.env.example``` Datei mit dem Command ```cp .env.example .env```, danach müssen wir die Datei editieren um die korrekten MySQL verbindungsdaten einzugeben.

```
DB_CONNECTION=mysql
DB_HOST=mysql-server
DB_PORT=3306
DB_DATABASE=phone-book
DB_USERNAME=phone-book
DB_PASSWORD=password
```

Damit Laravel richtig funktioniert müssen wir noch ein par dinge nach dem builden des containers ausführen. Dazu gehört das installieren von abhängikeiten und 2 weitere Schritte zum Setup von Laravel.

Ebenso müssen wir die nginx-konfiguration anpassen. Am besten erstellen wir dazu eine nginx konfigurationsdatei die wir beim builden als default konfiguration einsetzen.

Dazu fügen wir die Zeile ```COPY ./nginx.conf /etc/nginx/sites-available/default``` in unserem Dockerfile hinzu.

Nachdem wir das [Dockerfile](https://github.com/SayHeyD/M300-BIST/blob/master/docker-files/php-fpm/Dockerfile) angelegt haben, können wir das image builden:

1. In den selber Ordner wie das Dockerfile navigieren
2. ```docker build -t phone-book .``` ausführen
3. Mit ```docker images``` überprüfen ob ein image mit dem Namen *phone-book* vorhanden ist.

### Nginx Reverse-Proxy

Der Reverse-proxy soll die Verbindung von web-app container zum internet herstellen. somit ist der web-app container nicht direkt mit dem WAN verbunden um somit noch etwas mehr abgeschützt.

Der reverse-proxy Container muss folgende Eigenschaften aufweisen:

* Auf Port 80 von aussen erreichbar sein
* Mit dem phone-book-app eine verbindung als reverse-proxy herstellen können

Hierfür haben wir uns entschieden in einem [Dockerfile](https://github.com/SayHeyD/M300-BIST/blob/master/docker-files/reverse-proxy/Dockerfile) nginx manuell zu installieren.

Als erstes müssen wir eine reverse-proxy konfiguration anlegen. Diese wird beim builden zur Datei /etc/nginx/sites-available/default kopiert.

Danach haben wir noch ein [setup.sh](https://github.com/SayHeyD/M300-BIST/blob/david/docker-files/reverse-proxy/setup.sh) script angelegt um nach dem starten des containers den nginx service zu starten.

Nun können wir das image mit dem command ```docker build -t reverse-proxy .``` builden.
Nun können wir das image wie gewohnt mit ```docker run reverse-proxy``` starten.

### Alle Container zusammen ausführen

Natürlich können wir diese Container alle einzeln benutzen aber das Ziel ist das wir diese Container zusammen als ein Service bestehend aus Microservices laufen lassen. Um dies zu tun gibt es tools wie docker-compose oder kubernetes, hier benutzen wir jedoch einfach nur die Docker befehle und starten alle Container manuell und einzeln.

Als erstes starten wir den Datenbank-Server mit der Entsprechenden konfiguration.

Eigenschaften des Containers:

* Name: mysql-server
* Netzwerk: phone-book
* Umgebungsvariablen:
  * MYSQL_ROOT_PASSWORD: root_password
  * MYSQL_USER: phone-book
  * MYSQL_PASSWORD: password
  * MYSQL_DATABASE: phone-book
* Mounts:
  * Mysql Daten:
    * Source: $(pwd) (absoluter Pfad des aktuelles Verzeichnis)
    * Target: /var/lib/mysql
* Als deamon starte: Ja

Befehl zum starten des MySQL-Containers: ```docker run --name=mysql-server --network=phone-book --env="MYSQL_ROOT_PASSWORD=root_password" --env="MYSQL_USER=phone-book" --env="MYSQL_PASSWORD=password" --env="MYSQL_DATABASE=phone-book" --mount type=bind,source="$(pwd)"/data,target=/var/lib/mysql -d mysql:5.7```

Nun starten wir die web-app. Hier müssen wir weitaus weniger beachten, da das meiste beim builden des Images schon gemacht wird.

Eigenschaften des Containers:

* Name: phone-book-web
* Netzwerk: phone-book
* Als deamon starte: Ja

Befehl zum starten des MySQL-Containers: ```docker run --name=phone-book-web --network=phone-book -d phone-book```

Als letztes können wir nun den Reverse-Proxy starten. Um diesen zu starten ist auch keine grosse konfiguration nötig.

Eigenschaften des Containers:

* Name: reverse-proxy
* Netzwerk: phone-book
* Weitergeleitete-Ports: Container Port 80 auf Host Port 80
* Als deamon starte: Ja

Befehl zum starten des MySQL-Containers: ```docker run --name=reverse-proxy --network=phone-book -p 80:80 -d reverse-proxy```

Nun sollten wir die Web-App über die IP des Host-Servers erreichen können. Ebenfalls sollten wir die container mit dem command ```docker ps``` sehen können. Wenn alles gut gelaufen ist, sollte beim Status aller Container UP stehen.

Das Finale Produkt kann [hier](http://135.181.93.7/) eingesehen werden.

## Testen eines Docker Services (K3)

Um einen Docker Service zu testen gibt es mehrere Möglichkeiten. Die beste möglichkeit um die Funktionalität eines COntainers zu überprüfen sind die Logs von Docker.

Die Logs können mit dem Command ```docker logs [Container ID / Container Name]``` abgrufen werden und werden bei laufenden Containern fortlaufend aktualisert und können erneut abgerufen werden.

Bei laufenden Contaiern können wir sogar in die shell des Containers zugreifen. Dies geht mit dem Befehl ```docker exec -it [Container ID / Conatiner Name] bash``` somit könenn wir sogar befehle im Container ausführen und sehen was noch gemacht werden muss um den Container korrekt zum laufen zu bringen.

### Testfälle (K3)

#### Testen einer Verbindung zum Docker Service

Aufgabe: Verbindung per Web-browser aufbauen und einen neuen Datensatz analgen.
Erwartetes Ergebnis: Verbindung zur Website kann aufgebaut werden und Datensatz wird erfolgreich gespeichert.

Als erstes veruschen wir auf die [Website](http://135.181.93.7/) zuzugreifen. Hier wird die Website erfolgreich geladen. Nun klicken wir auf den Link "[Neuer Eintrag](http://135.181.93.7/create)". Hier lädt die creation-form. Nun füllen wir das Formular aus und klicken auf den Button "Erstellen". Nun lädt die startseite erneut und unser neuer Eintrag wird angezeigt.

Mit diesem Test haben wir folgendes getestet:

* Korrekte Funktion des Reverse-Proxies
* Korrekte Funktion der Web-App
* Korrekte Funktion der Datenbank
* Korrekte Verbindung der Container

#### Überprüfen der Logs des Web-Apps

Aufgabe: Überprüfen der Logs des Web-App Containers und auf Fehler überprüfen
Erwartetes Ergebnis: Keine Fehler ausser HTTP Fehlercodes werden in den Logs angezeigt.

Wir verbinden uns mit dem Server und holen uns die ID oder den Namen des Web-App containers.
Dies machen wir mit dem Befehl ```docker ps```. Der aktuelle Name des Containers ist phone-book-web. Nun können wir uns die Logs mit ```docker logs phone-book-web``` anzeigen lassen.

Die logs des Containers zeigen uns nun folgendes an:

```
Restarting nginx: nginx.
Application key set successfully.
Nothing to migrate.
[28-Sep-2020 17:22:38] NOTICE: fpm is running, pid 38
[28-Sep-2020 17:22:38] NOTICE: ready to handle connections
127.0.0.1 -  28/Sep/2020:17:49:18 +0000 "GET /index.php" 200
127.0.0.1 -  28/Sep/2020:17:49:21 +0000 "GET /index.php" 200
127.0.0.1 -  28/Sep/2020:18:47:27 +0000 "GET /index.php" 200
127.0.0.1 -  28/Sep/2020:18:50:17 +0000 "GET /index.php" 302
127.0.0.1 -  28/Sep/2020:18:50:18 +0000 "GET /index.php" 200
127.0.0.1 -  28/Sep/2020:18:54:20 +0000 "GET /index.php" 404
```

Die erste Zeile zeigt uns das Nginx neugestartet wird.
Danach kommen 2 Meldungen von laravel, welche auch keine Fehlermeldungen ausgeben und somit sind diese auch OK.
Die nächsten Zeilen, zeigen uns die Aktivität vom php-fpm Server und hier sehen wir das erste mal einen Fehlercode. Den HTTP Fehlercode 404. Dies ist aber nicht weiter schlimm, da dieser nur anzeigt das eine Seite nicht gefunden werden konnte.

## Image Bereitstellung (K6)

Die einfachste Methode um images bereitzustellen ist Docker Hub. Docker Hub bietet einem die möglichkeit direkt über das docker-cli seine images von einem Server auf den Docker-Hub hochzuladen.

Um Docker Hub zum hochalden voon Images nutzen zu können müssen wir uns zuerst einen [Account auf Docker Hub anlegen](https://hub.docker.com/signup).

Nachdem wir den Account angelegt haben, können wir versuchen unser phone-book image hochzuladen.

Zuerst müssen wir uns auf dem Server bei Docker Hub anmelden, das können mir mit dem Command:
```docker login --username=[Username]```

nun können wir unser Passwort eingeben und sollten eine positive Rückmeldung von Docker erhalten.

```
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Nun können wir unsere Images auf dem Server mit ```docker images``` anzeigen lassen und uns den tag des iamges merken, das wir hochladne möchten.

```
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
phone-book           latest              abb22853cc4c        25 hours ago        569MB
```

Bevor wir das image hochladen können, müssen wir den image tag für die repository vorbereiten.

Der neue tag muss wie folgt lauten: ```docker tag [IMAGE ID] [Username]/[Image-name]```
In userem fall wäre das also: ```docker tag abb22853cc4c sayhey/phone-book```

Danach können wir das image pushen: ```docker push [Username]/[Image-name]```
Für unser Beispiel: ```docker push sayhey/phone-book```

Nun können wir sehen, dass unser Image auf der [Docker Hub Website](https://hub.docker.com/repositories?ref=login) angezeigt wird.

<img src="https://github.com/SayHeyD/M300-BIST/blob/master/images/Bildschirmfoto%202020-09-28%20um%2022.45.47.png" alt="Docker Hub profile page" width="600px">

Das Image kann jetzt, solange das Image public ist von allen Docker nutzern mit einem Command auf ihren Server geladen werden.

```docker pull sayhey/phone-book```

Dies kann mit beliebig vielen images gemacht werden und ermöglicht einen einfahceren transfer zwischen Entwicklungs- und Produktionsenvoirnment.

## Persönlicher Wissensstand

Bisher waren mir "Container" oder "Docker" nicht wirklich ein Begriff. In meiner Arbeitsumgebung hatte ich nur mit gewöhnlichen VM's zu tun, welche mit VMWare Player oder Virtualbox erstellt wurden.
Die Möglichkeiten und die Vielzahl an Verwendungszewecken, welche mit Containersystemen bewerkstelligt werden können, sind mir bisher nicht bekannt gewesen.

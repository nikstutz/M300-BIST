# Sicherheit

Hier ist alles zur absicherung der Lernumgebung dokumentiert. Dazu gehören Reverse-Proxy konfiguration, Firewallkonfiguration, Benutzer & Rechte sowie der Netzwerkplan.


## Benutzer und Rechtvergabe (K4)

| Benutzer | verwendung|
|   ------ |------- |
| root | Linux System administrator/Superuser|
| ubuntu | Ubuntu default user|
|www-data| Apache Webserver|

Die Rechte der Benutzer werden ihnen mit einer Gruppenangehörigkeit zugeteilt. Jeder Benutzer is mindestens einer Gruppe zugeteilt kann aber auch in mehren sein, so können verschiedene services oder aktionen für einen Benutzer erlaubt oder verboten werden. 
Die oben aufgelisteten User sind alle Systenbenutzer und nicht benutzerkonten für reale Personen werden jedoch von realen personen verwendet. 

Benutzer befinden sich in der Datei /etc/passwd und die Gruppen in der Datei /etc/groups .


rwx: Rechte des Eigentümers
rws: Rechte der Gruppe
r-x: Recht von allen anderen (others)
Die Bedeutung der Buchstaben sind wie folgt:

r - Lesen (read):
Erlaubt lesenden Zugriff auf die Datei. Bei einem Verzeichnis können damit die Namen der enthaltenen Dateien und Ordner abgerufen werden (nicht jedoch deren weitere Daten wie z.B. Berechtigungen, Besitzer, Änderungszeitpunkt, Dateiinhalt etc.).
w - Schreiben (write):
Erlaubt schreibenden Zugriff auf eine Datei. Für ein Verzeichnis gesetzt, können Dateien oder Unterverzeichnisse angelegt oder gelöscht werden, sowie die Eigenschaften der enthaltenen Dateien bzw, Verzeichnisse verändert werden.
x - Ausführen (execute):
Erlaubt das Ausführen einer Datei, wie das Starten eines Programms. Bei einem Verzeichnis ermöglicht dieses Recht, in diesen Ordner zu wechseln und weitere Attribute zu den enthaltenen Dateien abzurufen (sofern man die Dateinamen kennt ist dies unabhängig vom Leserecht auf diesen Ordner). Statt x kann auch ein Sonderrecht angeführt sein.
s -Set-UID-Recht (SUID-Bit):
Das Set-UID-Recht ("Set User ID" bzw. "Setze Benutzerkennung") sorgt bei einer Datei mit Ausführungsrechten dafür, dass dieses Programm immer mit den Rechten des Dateibesitzers läuft. Bei Ordnern ist dieses Bit ohne Bedeutung.
s (S) Set-GID-Recht (SGID-Bit):
Das Set-GID-Recht ("Set Group ID" bzw. "Setze Gruppenkennung") sorgt bei einer Datei mit Ausführungsrechten dafür, dass dieses Programm immer mit den Rechten der Dateigruppe läuft. Bei einem Ordner sorgt es dafür, dass die Gruppe an Unterordner und Dateien vererbt 
d, die in diesem Ordner neu erstellt werden.
t (T) Sticky-Bit:
Das Sticky-Bit hat auf modernen Systemen nur noch eine einzige Funktion: Wird es auf einen Ordner angewandt, so können darin erstellte Dateien oder Verzeichnisse nur vom Dateibesitzer gelöscht oder umbenannt werden. Verwendet wird dies z.B. für /tmp.

## SSH (Secure Shell) 
SSH wird für die Sichere textbasierte verbindung zu geräten verrwendet und ist bestandteil von allen Linux Distributionen und ist der häufigste weg Linuxsystem ohne Grafische obefläche zu bedienen.

Hauptgrund der Verwendung:
Die Daten übertragung zwischen Server und Client sind verschlüsselt(Ablösung zu früherem protkoll Telnet das unverschlüsselte verbindung aufbaut). 
Daten werden nichtt manipuliert zwischen Geräten.

Für zusätzliche sicherheit können auch anstatt Passwörter Public-Keys verwendet werden um sich am Server zu Authentifizieren.
So können die rechte für die verbinddung schnell entzogen werden im falle das jemand diese nicht mehr haben sollte ohne das das Passwort geändert wird und neu abgelegt werden muss. 

Um zu verhindern, dass jeder mit SSH verbinden können, geben ich den Zugriff für bestimmte IP's frei

1. Ich erlaube auf der Firewall gewissen IP's den Zugriff via SSH:
```
sudo ufw allow from <DeineIP> to any port 22
```

2. Firewall Regel aktivieren:
```
 sudo ufw enable
```

3. Status überprüfen
```
 sudo ufw status
```

### SSH-Keys auf dem Server hinzufügen und Passwortauthentifizierung ausschalten

Wenn die SSH-Public-keys auf dem Server sind kann man die Passwortauthetifizierung ausschalten wodurch man die Sicherheit erneut erhöhen kann. Somit können nur noch neue Nutzer auf den Server zugreifen, wenn Ihr Key von einem Bereits authentifizierten USer hinzugefüht wird.

Die SSH Public-keys können im File ```~/.ssh/authorized_keys``` hinzugefügt werden.

Die Passwortauthentifizierung wird im File ```/etc/ssh/sshd_config``` ausgeschaltet werden.

In dem File gibt es die Zeilen:
```
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication yes
#PermitEmptyPasswords no
```

Hier ändert man die Zeile ```PasswordAuthentication yes``` auf ```PasswordAuthentication no```.

Danach startet man den Service neu ```service ssh restart```.

Nach dem Neustart können sich die Nutzer nicht mehr ohne SSH-Key anmelden.


## Firewall (K4)

Als Software für die Server-Firewalls verwenden wir ufw, da dies einfach zu benutzen ist und schon auf ubuntu vorinstalliert ist.

### Firewall

*Status*: aktiv
*Logging*: on(low)
*Default*: deny (incoming), allow (outgoing), disabled (routed)

| Port | Action | From |
| ----- | ----- | ----- |
| 22 | ALLOW | ANY |
| 22 | ALLOW | ANY |
| 22 | ALLOW | ANY |
| 80 | ALLOW | ANY |
| 8080 | ALLOW | ANY |
| 8081 | ALLOW | ANY |


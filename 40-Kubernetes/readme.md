# Container-Orchestration

## Kubectl Installieren

Kubectl kann über snap oder über apt-get installiert werden. Hier wird nur die apt-get methode aufgezeigt. beide möglichkeiten können auf der [Website von Kubernetes](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) eingesehen werden.

Um Kubectl zu isntallieren müssen nur wenige Befehle ausgeführt werden:

```sudo apt-get update && sudo apt-get install -y apt-transport-https```  
```curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -```  

```echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list``` sollte ```deb https://apt.kubernetes.io/ kubernetes-xenial main``` ausgeben.

```sudo apt-get update```  
```sudo apt-get install -y kubectl```

Nun ist kubectl auf dem aktuellen Server installiert und bereit um verwendet zu werden.

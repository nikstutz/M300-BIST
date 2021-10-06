FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install nginx -y

COPY ./default /etc/nginx/sites-available/default
COPY ./setup.sh /opt/setup.sh

CMD [ "bash", "/opt/setup.sh" ]
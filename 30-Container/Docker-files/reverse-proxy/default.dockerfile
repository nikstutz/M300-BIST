server {
    listen 80 default;
	listen [::]:80 default;

	server_name m300.davidlab.ch;

	root /var/www/html;
	index index.html index.nginx-debian.html;

	location / {
		proxy_set_header Host $host;
    	proxy_set_header X-Real-IP $remote_addr;
		proxy_pass http://phone-book-web;
	}
}
FROM nginx:latest
RUN apt-get update
RUN apt-get install -y certbot python3-certbot-nginx nano
COPY nginx.conf /etc/nginx/nginx.conf

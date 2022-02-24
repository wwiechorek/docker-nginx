FROM nginx:stable

ARG CERTBOT_EMAIL=william.wiechorek@gmail.com
ARG dokku.happs.in,mosquitto.dokku.happs.in

RUN  apt-get update \
      && apt-get install -y cron certbot python3-certbot-nginx bash wget \
      && certbot certonly --standalone --agree-tos -m "${CERTBOT_EMAIL}" -n -d ${DOMAIN_LIST} \
      && rm -rf /var/lib/apt/lists/* \
      && echo "PATH=$PATH" > /etc/cron.d/certbot-renew  \
      && echo "@monthly certbot renew --nginx >> /var/log/cron.log 2>&1" >>/etc/cron.d/certbot-renew \
      && crontab /etc/cron.d/certbot-renew


COPY nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 80
EXPOSE 443

VOLUME ./letsencrypt /etc/letsencrypt

CMD [ "sh", "-c", "cron && nginx -g 'daemon off;'" ]
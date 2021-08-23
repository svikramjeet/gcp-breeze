FROM jdecode/laravel-breeze-php8-pg-node:latest


# Refer ARG
ARG BUILD
ENV BUILD=${BUILD}

ARG PORT
ENV PORT=${PORT}

### Note : Change the IP (in the command below) to match the one that is to be used in the project
### Since this is editable, so this is not in the docker image, rather configurable via Dockerfile(this)
### Disable following 3 sections if you do not need HTTPS URLs on local


# Create local SSL certificate (to allow HTTPS URLs on local)
RUN if [ "$BUILD" = "local" ] ; then apt-get install -y ssl-cert ; else ls -al ; fi
RUN if [ "$BUILD" = "local" ] ; then openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj  "/C=IN/ST=PB/L=MOH/O=FNL/CN=210.81.1.1" -keyout ./docker-ssl.key -out ./docker-ssl.pem -outform PEM ; else ls -al ; fi
RUN if [ "$BUILD" = "local" ] ; then mv docker-ssl.pem /etc/ssl/certs/ssl-cert-snakeoil.pem ; else ls -al ; fi
RUN if [ "$BUILD" = "local" ] ; then mv docker-ssl.key /etc/ssl/private/ssl-cert-snakeoil.key ; else ls -al ; fi

# Setup Apache2 mod_ssl
RUN if [ "$BUILD" = "local" ] ; then a2enmod ssl ; else ls -al ; fi
# Setup Apache2 HTTPS env
RUN if [ "$BUILD" = "local" ] ; then a2ensite default-ssl.conf ; else ls -al ; fi


### Enable these based on your need
### Note : volume-mapping maps the current folder to the docker web root, so no need to copy files
### Since ENV VARs are setup in docker-compose.yml, so no need to have .env file
### .env.testing still might be required, depending on the configuration of phpunit.xml - enable it if needed

#COPY . /var/www/html

#COPY . /var/www/html
#RUN cp .env.example .env
#RUN cp .env.example .env.testing

RUN if [ "$BUILD" = "local" ] ; then ls -al ; else composer install --no-dev -n --prefer-dist ; fi
RUN if [ "$BUILD" = "local" ] ; then ls -al ; else npm install ; fi
RUN if [ "$BUILD" = "local" ] ; then ls -al ; else chmod -R 0777 public storage bootstrap ; fi
RUN if [ "$BUILD" = "local" ] ; then ls -al ; else npm run prod ; fi

RUN if [ "$BUILD" = "local" ] ; then ls -al ; else sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf ; fi

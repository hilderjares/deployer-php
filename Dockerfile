#BASE
FROM alpine:3.9 as base

RUN apk update \
    &&  apk add php7 php7-zip php7-xml php7-curl php7-pdo_mysql php7-json php7-dom php7-tokenizer php7-mbstring php7-iconv php7-gd php7-fileinfo php7-session libressl-dev php7-mongodb php7-redis \ 
    &&  apk add mysql-client && apk add curl

#DEPENDENCIES
FROM base as dependencies

COPY . /app

WORKDIR /app

RUN apk add composer git \ 
    &&  composer install --no-interaction --no-dev

#CLI
FROM dependencies as cli

RUN apk add php7-dom php7-xmlwriter php7-posix \ 
    &&  composer install 

RUN apk update --no-cache \
    && apk add --no-cache \
    openssh-client

RUN curl -LO https://deployer.org/deployer.phar && \
    mv deployer.phar /usr/local/bin/dep && \
    chmod +x /usr/local/bin/dep 

#APP
FROM base

COPY --from=dependencies /app /app

WORKDIR /app

CMD php -S 0.0.0.0:80 -t /app/public

EXPOSE 80
FROM php:7.0-fpm
ENV TIMEZONE Asia/Irkutsk
RUN apt-get update && apt-get install -y \
curl \
wget \
git \
libfreetype6-dev \
libjpeg62-turbo-dev \
libxslt-dev \
libicu-dev \
libmcrypt-dev
EXPOSE 9000
CMD ["php-fpm"]
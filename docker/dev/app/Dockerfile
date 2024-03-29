FROM ruby:2.6.7
ENV APP_ROOT /var/www/app
WORKDIR $APP_ROOT

RUN mkdir -p /root/tmp

RUN cp -p /etc/localtime /etc/localtime.UTC && \
    cp -p /usr/share/zoneinfo/Japan /etc/localtime

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
        && apt-get update && apt-get install -y yarn

RUN apt-get update -qq && \
    apt-get install -y  --no-install-recommends \
    yarn \
    nodejs \
    build-essential \
    libpq-dev \
    vim \
    nginx \
    supervisor \
    mariadb-client \
    imagemagick \
    graphviz \
    unzip

RUN gem install bundler

# RUN CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
#     wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ && \
#     unzip ~/chromedriver_linux64.zip -d ~/ && \
#     rm ~/chromedriver_linux64.zip && \
#     chown root:root ~/chromedriver && \
#     chmod 755 ~/chromedriver && \
#     mv ~/chromedriver /usr/bin/chromedriver && \
#     sh -c 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' && \
#     sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
#     apt-get update && apt-get install -y google-chrome-stable

RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# yarn install Preparation
RUN npm install n -g
RUN n 12.18.4

## nginx
RUN groupadd nginx
RUN useradd -g nginx nginx
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/dev.atlier.online.conf /etc/nginx/conf.d/dev.atlier.online.conf

## supervisor
RUN mkdir -p /var/log/supervisor
ADD supervisor/app.conf /etc/supervisor/conf.d/app.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]

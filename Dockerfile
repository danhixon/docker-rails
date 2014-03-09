# Rails Application
FROM danhixon/docker-sshd
MAINTAINER Dan Hixon <danhixon@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV APP_RUBY_VERSION 2.0.0-p353
ENV RAILS_ENV production

RUN apt-get -qq update
RUN apt-get -yqq upgrade
# libpq-dev is required for the pg gem
# libxml2 libxslt-dev libxml2-dev are required by nokogiri:
RUN apt-get -yqq install curl libpq-dev libxml2 libxslt-dev libxml2-dev

RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN su root -c 'source /usr/local/rvm/scripts/rvm && rvm install $APP_RUBY_VERSION --default'

ADD start_passenger /opt/start_passenger
ADD supervisor.conf /etc/supervisor/conf.d/rails.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]

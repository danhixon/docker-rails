# Rails Application

FROM zumbrunnen/base
MAINTAINER Dan Hixon <danhixon@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV APP_RUBY_VERSION 2.1.1
ENV RAILS_ENV production
ENV DB_USERNAME docker
ENV DB_PASSWORD docker

RUN apt-get -qq update
RUN apt-get -yqq upgrade
# libxml2 libxslt-dev libxml2-dev are required by nokogiri:
RUN apt-get -yqq install curl libpq-dev libxml2 libxslt-dev libxml2-dev

RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN su root -c 'source /usr/local/rvm/scripts/rvm && rvm install $APP_RUBY_VERSION --default'

ADD start_foreman /opt/start_foreman
ADD supervisor.conf /etc/supervisor/conf.d/rails.conf

EXPOSE 80

#ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["/opt/start_foreman"]

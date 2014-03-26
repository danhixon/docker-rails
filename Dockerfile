# Rails Application
FROM danhixon/sshd
MAINTAINER Dan Hixon <danhixon@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV APP_RUBY_VERSION 2.0.0-p353
ENV RAILS_ENV production

RUN apt-get -qq update
# libpq-dev is required for the pg gem,
# libxml2 libxslt-dev libxml2-dev are required by nokogiri,
# Need javascript engine for the asset pipeline
# Need git in order for capistrano to check out code from repo
# I like view files in vim:
RUN apt-get -yqq install curl build-essential libssl-dev zlib1g-dev libpq-dev libxml2 libxslt-dev libxml2-dev nodejs git-core vim && apt-get clean

# Install rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
 
# install ruby-build
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

ENV CONFIGURE_OPTS --disable-install-doc
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c '/root/.rbenv/bin/rbenv install $APP_RUBY_VERSION; /root/.rbenv/bin/rbenv global $APP_RUBY_VERSION; gem install bundler;'

# rbenv instead of rvm
#RUN \curl -sSL https://get.rvm.io | bash -s stable
#RUN su root -c 'source /usr/local/rvm/scripts/rvm && rvm install $APP_RUBY_VERSION --default'

# start_passenger also writes the current environment variables into the PAM config file.
ADD start_passenger /opt/start_passenger
ADD passenger.conf /etc/supervisor/conf.d/passenger.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
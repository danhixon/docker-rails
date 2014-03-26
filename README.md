docker-rails
============

A simple Docker Image for running Ruby on Rails Rails applications with Passenger. It is based off [danhixon/docker-sshd](https://github.com/danhixon/docker-sshd) so capistrano can connect to it via ssh.

## Starting The Container

`docker run -d -p 384743:22 -name <containername> -link <dbcontainer>:db -v /var/www/<dir>:/var/www/<dir> -e APP_NAME=<appname> -e DB_USERNAME=$PG_APPUSER -e DB_PASSWORD=$PG_APPUSER_PASSWORD AUTHORIZED_KEYS="$(cat ~/.ssh/id_rsa.pub)" danhixon/rails`

When the container starts, the necessary gems will be installed, then the DB will be prepared (created and migrated), and eventually, Passenger will be started in standalone mode. See [the start script](../master/start_passenger) which will be triggered by `supervisord`.

You will also have ssh access by virtue of the [danhixon/sshd](https://github.com/danhixon/docker-sshd) base image.

###Remarks
1. Link to a DBMS (`<dbcontainer>`) of your choice. It works with danhixon/ubuntu-postgres.
2. `<dir>` must be equal to `$APP_NAME` and - when using Capistrano - be the same on the host and in the container for deployments (because of absolute symlinks)
3. Use AUTHORIZED_KEYS to grant sshd access to your deployment user.
4. Override these default environment variables as needed (using `-e KEY=value`):
 * `RAILS_ENV=production`


## Database Connection
When linked to another container holdig your database, use something like this in `config/database.yml`:
```
production:
  adapter: postgresql
  database: betastore_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_PORT_5432_TCP_ADDR'] %>
  port: <%= ENV['DB_PORT_5432_TCP_PORT'] %>
  pool: 5
  timeout: 5000
```

## Serving The App

To access your Rails app from "the outside", install a reverse proxy on the host system and point it to the container's IP on port 80.

I use Apache2. Here's how to set it up:

1. Install Apache: `sudo apt-get install apache2`
2. Create a new site under `/etc/apache2/sites-available`, e.g. a file called `appname`:

```
<VirtualHost *:80>
    ServerName appname.your.domain

    ErrorLog ${APACHE_LOG_DIR}/appname-error.log
    CustomLog ${APACHE_LOG_DIR}/appname-access.log combined

    ProxyRequests Off
    ProxyPass / http://containerip:80/
    ProxyPreserveHost On

    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
</VirtualHost>
```

N.B.: You can get the container's IP address by using: `docker inspect -format '{{ .NetworkSettings.IPAddress }}' <containername>`

3. Enable the modules `proxy` and `proxy_http`:

```
sudo a2enmod proxy
sudo a2enmod proxy_http
```

4. Enable your site and restart Apache:

```
sudo a2ensite yoursite
sudo service apache2 restart
```

5. Test connection by pointing your browser to http://appname.your.domain


#!/usr/bin/env bash
echo 'start installing Geode geonode version alpha-beta'
apt-get install -y git
apt-get install -y python-pip
pip install virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/.venvs
source /usr/local/bin/virtualenvwrapper.sh
export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads
mkvirtualenv geode_geonode --system-site-package

echo ' install in the new active local virtualenv'
workon geode_geonode
pip install psycopg2
cd /var/www/
#django-admin startproject geode_geonode --template=https://github.com/Geode/geode_geonode/archive/master.zip -epy,rst
git clone https://github.com/Geode/geode_geonode
pip install -e geode_geonode
cd /var/www/geode_geonode/
cp geode_geonode/local_settings.py.sample geode_geonode/local_settings.py
sed -i 's/SITENAME = '\''GeoNode'\''/SITENAME = '\''Geode-GeoNode'\''/g' geode_geonode/local_settings.py
sed -i 's/SITEURL = '\''http:\/\/localhost\/'\''/SITEURL = '\''http:\/\/localhost:2780\/'\''/g' geode_geonode/local_settings.py

#ln -s /etc/geonode/local_settings.py  /var/www/geode_geonode/geode_geonode/local_settings.py
# edit the Apache conf to prevent the error:
# Could not reliably determine the server s fully qualified domain name, using 127.0.1.1 for ServerName"
sed -i "$ a\ServerName localhost" /etc/apache2/apache2.conf
sed -i 's/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/WSGIScriptAlias \/ \/var\/www\/geode_geonode\/geode_geonode\/wsgi.py/g' /etc/apache2/sites-available/geonode.conf
#sed -i 's/WSGIScriptAlias \/ \/var\/www\/geode_geonode\/geode_geonode\/wsgi.py/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/g' /etc/apache2/sites-available/geonode.conf
cp /setup/wsgi.py /var/www/geode_geonode/geode_geonode/wsgi.py
service apache2 restart
cd /var/www/geode_geonode/
python manage.py collectstatic --noinput
echo 'finished installing Geode geonode, test http://localhost:2780/'
echo 'dont forget to finish creating superuser, doing the following steps : '
echo 'vagrant ssh'
echo '#note for windows user: set PATH=%PATH%;c:\Program Files (x86)\Git\bin'
echo 'sudo su'
echo '#activate virtualenv geode_geonode, one way, with wrapper :'
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python'
echo 'export WORKON_HOME=/home/.venvs'
echo 'source /usr/local/bin/virtualenvwrapper.sh'
echo 'export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads'
echo 'workon geode_geonode'
echo 'geonode createsuperuser'

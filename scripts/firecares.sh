set -e

echo '{
  "run_list": [
    "role[geoshape_core]",
    "recipe[rogue::iaff]"
  ],
  "rogue": {
    "django_maploom": {
      "auto_upgrade": true
    },
    "rogue_geonode": {
      "branch": "iaff",
      "python_packages": ["uwsgi", "psycopg2", "git+git://github.com/ROGUE-JCTD/iaff_geoshape.git"]
      }
    }
}' > /opt/chef-run/dna.json

sed -i 's/django.db.backends.postgresql_psycopg2/django.contrib.gis.db.backends.postgis/g' /opt/chef-run/cookbooks/rogue/templates/default/local_settings.py.erb
sudo -u postgres psql -c "create extension postgis" -d geonode
/usr/local/rvm/gems/ruby-2.0.0-p353/bin/chef-solo -c /opt/chef-run/solo.rb -j /opt/chef-run/dna.json
/var/lib/geonode/bin/python /var/lib/geonode/rogue_geonode/manage.py syncdb --all --noinput --no-initial-data
cd /tmp
wget http://firecares.iaff.org/static/firestation.sql.gz
chmod 755 firestation.sql.gz
sudo su postgres 
gunzip -c firestation.sql.gz | sudo -u postgres psql -d geonode

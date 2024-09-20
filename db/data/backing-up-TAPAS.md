### Backing up tapas_rails

https://github.com/samvera/hyrax/wiki/Backup-and-Restoration

Database settings: https://github.com/NEU-DSG/tapas_rails/blob/develop/config/database.yml
For passwords, check `tapas_rails/tapas_rails/application.yml`

#### Rails database

As root: `mysqldump --user=tapas_rails -p tapas_rails_staging > /tmp/rails-staging_DATE.sql`. The MySQL password can be found in application.yml (via W. Jackson).

This database contains:

* institutions
* news items
* static webpages
* searches
* users
* view packages

#### Redis

Make a copy of the database at /var/lib/redis/dump.rdb

#### Fedora datastore

Fedora v3.x instructions for making backups: <https://wiki.lyrasis.org/pages/viewpage.action?pageId=66585946>

I used `zip -r /tmp/fedora-bak_DATE.zip data/ install/install.properties`

* /opt/fedora/data/datastreamStore: HTML fragments for the reading interface; upload timestamp and other info
* /opt/fedora/data/objectStore: versioning, limited OAI-DC metadata

#### Solr

The Hydrax walkthrough suggests that there's no need to backup Solr, but I'm not sure whether to trust that.

Solr v6.6 documentation on backups: <https://lucene.apache.org/solr/guide/6_6/making-and-restoring-backups.html>

As myself: `curl -v "http://localhost:8080/solr/development/replication?command=backup&location=/tmp` Then zip the snapshot directory.

### Updating Drupal

First, log in to the VM as root: `dzdo su - root`
DB root password can be found at /var/www/html/sites/default/settings.php

Updating with `drush`:

1. Put site in maintenance mode.
  1. Configuration > Development > Maintenance mode
  2. Check the "Put site into maintenance mode" button
  3. Test the site's availability in a different browser or private window
2. Backup MySQL databases. _This is optional_, since a Drush backup will include a backup of the `tapas_drupal` database.
  1. Create a dump of database info: `mysqldump -p --all-databases > /tmp/all-db_DATE.sql` OR specific databases: `mysqldump -u root --databases DBONE DBTWO > /tmp/all-db_DATE.sql`
  2. Check which databases have been dropped and backed up: `grep -i "Current database:" /tmp/all-db_DATE.sql`
3. Backup the sites directory:
  1. `cd /var/www/html`
  2. `drush archive-dump`. (This takes a while.)
4. Update Drupal core: `drush pm-update drupal`.
5. Check the report of available updates to Drupal core and modules: `drush pm-updatestatus` _(optional)_
6. Update modules: `drush pm-update`. Useful parameters: `--no-core` (don't update Drupal core); `--security-only` (only apply security updates); `captcha honeypot` (only update the 'Captcha' and 'Honeypot' modules, for example)
7. Move database backup file to /mnt/TAPASprod-Data
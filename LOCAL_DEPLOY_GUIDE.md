Local Deploy Guide
===========
This document outlines steps for configuring your environment to run TAPAS as it exists in its current state of development (see Github issue [#92](https://github.com/NEU-DSG/tapas_rails/issues/92)) from your machine.

## Installing TAPAS and dependencies

First, get a local copy of the `tapas_rails` repository and check out the right branch, e.g.:

```shell
git clone https://github.com/NEU-DSG/tapas_rails.git
cd tapas_rails
git checkout develop
```

If you're on a Mac, you'll need a package manager to install some software dependencies. You'll also need to know how to install packages with that manager.

We recommend the [Homebrew](https://brew.sh/) package manager. To install packages with Homebrew, use the command pattern `brew install PKG_NAME`.

### Install Ruby

TAPAS currently requires Ruby at version 2.7.7.

1. [Install Ruby Version Manager (RVM)](http://rvm.io/rvm/install), using the RVM instructions.
2. Install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store.
    1. Install the Command Line Tools package with `xcode-select --install`.
3. Install the `automake` package with your package manager.
4. Install the `openssl@3` package with your package manager.
5. Install Ruby:
    1. Try RVM's default install, `rvm install ruby-2.7.7` (or the shorthand `rvm install 2.7.7`).
    2. If the installation failed because the ruby source couldn't be compiled, provide the OpenSSL path, e.g.: `rvm install ruby-2.7.7 -C --with-openssl-dir='/opt/homebrew/bin/openssl'`.

### Install Apache Solr

The latest version of Apache Solr v8.x (currently v8.11.4) is recommended.

1. Download the [binary release from Apache](https://solr.apache.org/downloads.html).
2. Extract the Solr folder from the tarball (with the `tar` command or your OS's archive manager).
3. Go to the Solr directory: `cd path/to/solr-8.11.2`
4. Start the Solr server: `bin/solr start`
5. Create a Solr core for TAPAS:
    1. Run the core generator: `bin/solr create -c tapas-core`
    2. Go to the core configuration directory: `cd server/solr/tapas-core/conf`
    3. Create a configuration file: `touch solrconfig.xml`
    4. Create a schema file: `touch schema.xml`
    5. Populate each file with the contents of the files received with the same names using the text editor of your choice. **??? Can we make this easier?**
6. Confirm that the new core has been configured correctly:
    1. In your browser, open the [Solr Admin Dashboard](http://localhost:8983/solr/#/)
    2. Click on the **Core Selector** dropdown button on the left side of the page.
    3. Verify that `tapas-core` is listed.

To stop Solr, run `./bin/solr stop`.

### Install MySQL
The latest version of MySQL (currently v9.0.1) is recommended.

1. Install the `mysql` package with your package manager.
2. If you are on a fresh install, with Homebrew:
    1. Start MySQL: `brew services start mysql`
    2. Configure the root user's password with `mysql_secure_installation`
3. Set up a MySQL user for TAPAS:
    1. Log into MySQL as the root user: `sudo mysql -u root -p`
    2. Create the TAPAS user, e.g. `create user 'tapas_user'@'localhost' identified by 'changeThisPassword!';`
    3. Make sure the new user has permissions to create and edit databases: `grant all on *.* to 'tapas_user'@'localhost' with grant option;`
    4. Quit the MySQL command line interface: `\q`

### Install and configure Rails

TAPAS currently requires Ruby on Rails at version v5.2.6.

0. Navigate to your copy of `tapas_rails`.
1. Install the Rails gem: `gem install rails -v 5.2.6`.
2. Configure your environment variables:
    1. Create a plain text file named `.env`.
    2. Define the environment variables you will need, following the [syntax required by dotenv](https://github.com/bkeepers/dotenv/blob/main/README.md#usage). An example appears below.
    3. Save the `.env` file to the `tapas_rails` directory.

```
MYSQL_USER=tapas_user
MYSQL_PASSWORD=changeThisPassword!

# Starter users for testing
DUMMY_ADMIN_EMAIL=admin@example.org
DUMMY_ADMIN_PASSWORD=changeThisPasswordToo!
DUMMY_DEBUG_EMAIL=debug@example.org
DUMMY_DEBUG_PASSWORD=definitelyChangeThisAsWell!
```

3. Install the `imagemagick` package with your package manager.
4. Install the `mysql2` gem:
    1. If you installed OpenSSL and/or MySQL with Homebrew, try: `gem install mysql2 -- --with-mysql-dir=$(brew --prefix mysql) --with-openssl-dir=$(brew --prefix openssl@3)`
    2. The installation above should complete without error. If it doesn't, check the [`mysql2` installation instructions](https://github.com/brianmario/mysql2#installing) for options that might correspond to the errors you're seeing. 
    3. *Do __not__ proceed until `mysql2` has installed successfully.*
5. Install all other gems required by TAPAS: `bundle install`.
6. Set up the TAPAS databases:
    1. Create the app databases: `rails db:create`
    2. Create tables within the databases: `rails db:migrate`

### Create test data

To create fake users, projects, etc. for testing purposes, run `rails dummy_data_generator:run_all`. This task encompasses several other `dummy_data` tasks that can be run independently. (For a list, see `rails --tasks dummy_data_generator`.)

After creating dummy data, the TAPAS MySQL databases and Apache Solr should have new records you can examine.

To check the contents of the MySQL databases:

1. Enter the MySQL CLI as root or your TAPAS user, e.g.: `mysql -u tapas_user -p`
2. Check which databases are available: `show databases;`. (Rails will have created one database for each environment, e.g. "development" and "test".)
3. Enter the TAPAS development database: `use tapas_rails_development;`.
4. Check what tables are available in this database: `show tables;`.
5. You can examine all fields in a table with something like ` select * from users;`. (Read up on the [MySQL SELECT statement](https://dev.mysql.com/doc/refman/8.0/en/select.html) for more complex SQL queries.)
6. When you're done, quit the MySQL CLI with `\q`.

To check the contents of the Solr core:

1. In your browser, go to the [Solr Admin Dashboard](http://localhost:8983)
2. Click on the "Core Selector" dropdown button
3. Select `tapas-core`
4. Click on the "Overview" tab to view the number of records indexed

Solr will not have information on TAPAS users, but should contain "documents" representing projects, collections, etc.


## Run TAPAS

1. **start the server**: `rails server`
2. **visit**: `http://localhost:3000`
3. **Happy coding!**

### Troubleshooting:

- stop the server: `ctrl C`
- Review the **Notes for OSX** section of the [README](README.md) to configure additional environment dependencies. i.e., nokogiri, openssl, libv8


## Test framework

- [rspec-rails](https://github.com/rspec/rspec-rails)
- [factory_bot](https://github.com/thoughtbot/factory_bot_rails)

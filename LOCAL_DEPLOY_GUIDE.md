Local Deploy Guide
===========
This document outlines steps for configuring your environment to run TAPAS as it exists in it's current state of development (see Github issue [#92](https://github.com/NEU-DSG/tapas_rails/issues/92)) from your machine.

## System dependencies
Ensure the following are installed:
- [Ruby 2.7.7](https://www.ruby-lang.org/en/downloads/)
- [Rails 5.2.6](https://github.com/rails/rails)
- [MySQL 9.0.1](https://formulae.brew.sh/formula/mysql#default) via Homebrew (recommended)
- [Apache Solr 8.11.2](https://solr.apache.org/guide/6_6/installing-solr.html)

## Test framework
- [rspec-rails](https://github.com/rspec/rspec-rails)
- [factory_bot](https://github.com/thoughtbot/factory_bot_rails)

## Usage
### Install:
1. **clone the application**: `git clone https://github.com/NEU-DSG/tapas_rails.git`
2. **checkout branch _92-core-files_**: `git checkout 92-core-files`
3. **configure app dependencies**:
    - `cd path/to/tapas_rails`
    - `bundle install`
4. **configure Solr**:
   - go to the Solr directory: `cd path/to/solr-8.11.2`
   - start the Solr server: `bin/solr start`
   - create the Solr core:
     - run the core generator: `bin/solr create -c tapas-core`
       - go to the core configuration directory: `cd server/solr/tapas-core/conf`
         - create a configuration file: `touch solrconfig.xml`
         - create a schema file: `touch schema.xml`
         - populate each file with the contents of the files received with the same names using the text editor of your choice.
   - confirm Solr cores have been configured correctly
       - go to the **[Solr Admin Dashboard](http://localhost:8983/solr/#/)**
       - click on the **Core Selector** dropdown button on the left side of the page to verify _tapas-core_ is listed
5. **set up the database**: _*assumes successful MySQL install_
    - go to the application directory
    - run the following terminal commands:
      - create the app database: `rails db:create`
      - create database tables: `rails db:migrate`
      - create data to populate tables: `rails dummy_data_generator:run_all`
6. **confirm the Solr index includes records created in step 4, excluding users**
    - go to the **[Solr Admin Dashboard](http://localhost:8983/solr/#/blacklight-core/query?q=*:*&q.op=OR&indent=true)**
    - click on the **Core Selector** dropdown button
    - select _tapas-core_
    - click on the **Overview** tab to view the number of records indexed

### Run:
1. **start the server**: `rails server`
2. **visit**: `http://localhost:3000`
3. **Happy coding!**

#### Troubleshooting:
- stop the server: `ctrl C`
- Review the **Notes for OSX** section of the [README](README.md) to configure additional environment dependencies. i.e., nokogiri, openssl, libv8

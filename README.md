tapas_rails
===========
[![Build Status](https://travis-ci.org/NEU-DSG/tapas_rails.svg?branch=master)](https://travis-ci.org/NEU-DSG/tapas_rails)

Hydra Head for the TAPAS webapp.


## Hungry for more TAPAS?
[TAPAS website](http://www.tapasproject.org/)

[TAPAS public documents, documentation, and meeting notes on GitHub](https://github.com/NEU-DSG/tapas-docs)

[TAPAS webapp (Drupal) on GitHub](https://github.com/NEU-DSG/tapas)

[TAPAS Hydra Head on GitHub](https://github.com/NEU-DSG/tapas_rails)

[TAPAS virtual machine provisioning on GitHub](https://github.com/NEU-DSG/plattr)


---
Deploy
  - from within tapas_rails directory of vagrant env
  - To staging : bundle exec cap staging deploy
  - To prod : bundle exec cap production deploy

Tomcat
  - check status
    - ssh in to box as user with root privileges
    - on staging: sudo service tomcat status
    - on prod: sudo service tomcat7 status
  - restart/stop/start
    - ssh in to box as user with root privileges or tapas_rails user
    - on staging: sudo service tomcat restart (or start or stop)
    - on prod: sudo service tomcat7 restart (or start or stop)
  - there are custom scripts which start tomcat as the tapas_rails user

Fedora (run by Tomcat)
  - check status
    - on staging: go to http://railsapi.tapasdev.neu.edu:8080/fedora
    - on prod: go to http://railsapi.tapas.neu.edu:8080/fedora
    - should see description of fedora install
  - restart/stop/start - controlled by Tomcat

Solr (run by Tomcat)
  - check status
    - on staging: go to http://railsapi.tapasdev.neu.edu:8080/solr
    - on prod: go to http://railsapi.tapas.neu.edu:8080/solr
    - should see admin interface without any giant red or yellow warnings along the top
  - run query
    - go to admin interface (see urls above)
    - choose the right core from the dropdown on the left(development for rails app - TODO - check on this)
    - click query in the menu on the left
    - perform searches here (can use various formats of response like xml and json)

Apache
  - check status
    - go to any known url to see if there is a connection
  - restart/stop/start
    - sudo service httpd restart/stop/start

Passenger (run by Apache)
  - check status
    - on staging: go to http://railsapi.tapasdev.neu.edu - TODO - check on what you should see
    - on prod: go to http://railsapi.tapas.neu.edu - should see view_packages info
  - restart/stop/start
    - restart/stop/start apache (see above)

Resque
  - check queue
    - on staging: go to http://railsapi.tapasdev.neu.edu/resque
    - on prod: go to http://railsapi.tapas.neu.edu/resque
    - if jobs are processing you'll see them in the bottom part of the page
    - if jobs are queued you'll see them in the queued number in the upper left
    - if jobs have failed, you'll see them in the failed number in the upper left
    - can check via command line by logging into the server (as yourself) and running `sudo service resque status`
  - restart/stop/start
    - sudo service resque restart/stop/start (issues a cap command)




To run the job that reruns all of the core_files through the reading interface building:
  `RAILS_ENV=production bundle exec thor tapas_rails:rebuild_reading_interfaces 500`
  where 500 is the number of records you would like to run (could do a query for number of core_files in solr before performing the thor task)


  bundle exec cap production resque:restart

To modify the main menu
  - open the menu.en.yml file and modify/reorder/add/delete values where necessary


## Development

To get started developing TAPAS, first install the required software:

- Ruby 2.6.3
- Rails 5.2
- MySQL 5.x

Then follow these steps:

0. Clone this repository and cd to the repository directory
1. Create a mysql database and import the TAPAS sql file
2. Configure application.yml file with correct parameters
4. cd to project directory && `bundle install`
5. Run `rails s` to start the application

To get TEI files to render properly, you'll need to use something like [`xslt3`](https://www.npmjs.com/package/xslt3)
to compile them to a SEF JSON representation that can be used by the in-browser XSLT processor.
(See [app/views/core_files/_reading_interface.html.erb](app/views/core_files/_reading_interface.html.erb).)

#### Notes for OSX

 - installing nokogiri on OSX: `$ gem install nokogiri -- --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/libxml2 --use-system-libraries`
 - configuring bundle install with correct openssl from brew:
 ```
 $ bundle config --global build.mysql2 --with-opt-dir="$(brew --prefix openssl)"
 $ bundle install
 ```
 - if running with MAMP: `gem install mysql2 -- --with-mysql-config=/Applications/MAMP/Library/bin/mysql_config`


 - install libv8 on OSX with the following:
  `$ brew install v8@3.15`
  `$ bundle config build.libv8 --with-system-v8`
  `$ bundle config build.therubyracer --with-v8-dir=$(brew --prefix v8@3.15)`
  `$ bundle install`

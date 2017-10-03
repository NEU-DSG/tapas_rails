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

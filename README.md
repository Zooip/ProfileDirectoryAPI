# Profile Directory API #
[![Code Climate](https://codeclimate.com/github/Zooip/ProfileDirectoryAPI/badges/gpa.svg)](https://codeclimate.com/github/Zooip/ProfileDirectoryAPI) <a href="https://codeclimate.com/github/Zooip/ProfileDirectoryAPI/coverage"><img src="https://codeclimate.com/github/Zooip/ProfileDirectoryAPI/badges/coverage.svg" /></a>
## What is this ? ##

Enable acces to an user profile directory with an OAuth 2 protected API using JSONAPI specifications (jsonapi.org)

**This project is still under active development and can't be used in its current state**

This is proposed as a working base to manage authorization and resources definition of a much wider API.

* Follows JSONAPI specifications (jsonapi.org) with [JSONAPI Resources](https://github.com/cerebris/jsonapi-resources) gem
* Uses Oauth 2 gem [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) to protect resources
* Relies heavily on scopes to manage authorisation granularity
* Uses multiple databases for API engine and master data
* Displayed profile attributes depend on granted scopes


## Databases ##
This application uses 2 different databases to keep master data separated from API internal implementation.

Master data database credentials are under *master\_data\_db* in config/databases.yml

```
#!yaml
#
master_data_db:
  development:
    <<: *default
    database: masterdata_dev
    username: masterdata_dev
    password: password1

  test:
    <<: *default
    database: masterdata_test
    username: masterdata_dev
    password: password1

  #
  production:
    <<: *default
    database: masterdata_prod
    username: masterdata_prod
    password: <%= ENV['MASTER_DATA_DATABASE_PASSWORD'] %>

development:
  <<: *default
  database: apiengine_dev
  username: apiengine_dev
  password: password1

test:
  <<: *default
  database: apiengine_test
  username: apiengine_test
  password: password1

#
production:
  <<: *default
  database: apiengine_prod
  username: apiengine_prod
  password: <%= ENV['MASTER_DATA_DATABASE_PASSWORD'] %>
```

Rails automatically creates migrations under db/migrate directory. Masterdata related migrations have to be manually moved to db/migrate_master_data

This migrations can the be triggered with
    rake master_data:db:migrate

This task is defined in /lib/task/migrate.rake

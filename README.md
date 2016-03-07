# Profile Directory API #
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


## License MIT ##

Copyright (c) 2016 Alexandre Narbonne

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
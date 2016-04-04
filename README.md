# Chicago Public Library - Digital Learn [![Code Climate](https://codeclimate.com/github/PublicLibraryAssoc/cpldl/badges/gpa.svg)](https://codeclimate.com/github/PublicLibraryAssoc/cpldl) [![Test Coverage](https://codeclimate.com/github/PublicLibraryAssoc/cpldl/badges/coverage.svg)](https://codeclimate.com/github/PublicLibraryAssoc/cpldl/coverage)

## Install Dependencies
RVM
Postgresql
Redis

## Starting a new project using this template

* Clone this project from Github
* Create a new gemset with 'rvm gemset create cpldl' (assumes rvm is installed)
* Run `bundle install`
* Run `rake db:migrate`

## Up and Running.

* Ruby version
  ruby 2.2.3

* Database creation
  - `rake db:create db:migrate`

* How to run the test suite
  - `rspec`    : testing suite
  - `rubocop`  : for syntax and code smells
  - `brakeman` : for security smells


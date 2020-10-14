# DigitalLearn

A Public Library Association curated collection of course materials to be used for in-person
digital literacy courses, online trainings on developing courses and content, and a community of
practice for digital literacy trainers.

## Contributions

If you find a bug, please open an issue.

Feel free to submit a Pull Request if you'd like to contribute. Follow instructions below to set up and run the application in a development environment. If you do choose to contribute, please include tests for your code and fix any formatting issues uncovered with RuboCop.

## Getting Started

DigitalLearn is built on top of Ruby on Rails. A basic understanding of working with Rails is
required to stand up a new DigitalLearn site.

### Dependencies

- Ruby 2.6.4
- Rails 5.2.3
- Postgresql v 9.4.5

### Update Secrets

- Update secrets.yml with your values

### Database Creation

- Update database.yml.example with your credentials
- Run `rake db:create db:migrate db:seed`

### Install Gems

- `bundle install`

### Start Server

- `rails s`

In order to test subdomain functionality, consider using lvh.me:
Run server with `rails s -b lvh.me`, then visit `_subdomain_.lvh.me:3000`

Alternatively, you can create a tunnel to your localhost with [ngrok](https://github.com/inconshreveable/ngrok).

### Run Tests

- `rspec`

### Run rubocop linter

- `rubocop`

## Adding new Subsites

View the documentation on [Adding a new Subsite](/docs/adding_a_subsite.md)

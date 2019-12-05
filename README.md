# DigitalLearn

A Public Library Association curated collection of course materials to be used for in-person
digital literacy courses, online trainings on developing courses and content, and a community of
practice for digital literacy trainers.

## Contributions

Please ask before opening a pull to add features, as we must weigh the impact against current
implementations of this code base.

That said, if you find a bug, please do open an issue!

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

## Adding new Subsites

View the documentation on [Adding a new Subsite](/docs/adding_a_subsite.md)

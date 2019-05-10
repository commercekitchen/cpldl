# DigitalLearn

A Public Library Association curated collection of course materials to be used for in-person
digital literacy courses, online trainings on developing courses and content, and a community of
practice for digital literacy trainers.

## Contributions

Please ask before opening a pull to add features, as we must weigh the impact against current
implementations of this code base.

That said, if you find a bug, please do open an issue!

## Getting Started

DigitalLearn is built on top of Ruby on Rails.  A basic understanding of working with Rails is
required to stand up a new DigitalLearn site.

### Dependencies

* Ruby 2.2.9
* Rails 4.2.10
* Postgresql v 9.4.5

### Update Secrets

* Update secrets.yml with your values

### Database Creation

* Update database.yml.example with your credentials
* Run `rake db:create db:migrate db:seed`

### Install Gems

* `bundle install`

### Start Server

* `rails s`

## Adding a new Subsite

### Necessary information

* New organization name (ex/ "East Baton Rouge Public Library")
* Subdomain name (ex/ "ebrpl")
* New organization url (ex/ "https://www.ebrpl.com")
* Branch information
* Program information
* Header logo (full color)
* Footer logo (white & transparent)
* Google analytics ID
* Various site texts in English and Spanish
  - Banner Greeting
  - Subheader text (user dashboard)
  - (optional) Retake quiz prompt

### Prior to deploy

* Create necessary color variables in `_vars.scss`:

  ```
  /* NEW_SUBDOMAIN */
  $new_subdomain-blue: #2C3590;
  $new_subdomain-light-blue: #147BBA;
  $new_subdomain-gray: #716C6B;
  ```

* Create a new file for the subsite styles in `assets/stylesheets/subdomains/`. This file should define a class which matches your new subdomain (ex/ `.new_subdomain {...}` for `new_subdomain.digitallearn.org`). This class should include 6 SASS mixins for different application components:
  - `color_scheme` The main color scheme options for headings, links and colored text.
  - `banner` Banner background & text colors and font sizes (if specified)
  - `buttons` Defines background and text color for buttons
  - `course_widget` Course widget boxes
  - `lesson_block` Lesson widget boxes, including arrow and check icon colors
  - `icons` All other site icons

  These components each take several color parameters, for which you'll use the colors defined for the new subsite in `_vars.scss`.

* Add subsite Footer logo and logo link through subsite admin panel customization pages

* Customize subsite texts through admin panel
  - Custom banner greeting text
  - Additional banner greeting content
  - User dashboard subheader
  - Retake quiz prompt (usually just 'Retake the Quiz' unless otherwise specified)
  - (misspelled key in yaml file) Explanation of course colors - courses to be completed are displayed with the colors passed to the `course_widget` SASS mixin in the `_new_subdomain.scss` class. Completed courses are displayed in Gray by default. This sentence usually ends with the prompt "To add more to your plan,"

* Create google analytics javascript partial in `views/shared/` as `_ga_new_subdomain.html.erb`. Use one of the existing GA files as a guide. Simply replace the analytics ID with the appropriate ID for the new subdomain:
  ```
  ga('create', 'new_analytics_id', 'auto', {
    userId: userGaId
  });
  ```

* Add an entry to `views/shared/ga_event_tracking.html.erb` to track outgoing links to the new library's home page:
  ```
  $("footer").on("click", ".link-new_subdomain", function(){
    ga("send", "event", "external link", "click", "New Library Name");
  });
  ```

* Create organization to test/adjust subsite styles:
  ```
  Organization.create(name: "New Library", subdomain: "new_subdomain", branches: true, accepts_programs: false)
  ```

  Notes: Set branches to `false` if subsite doesn't require branch specification on login. Set accepts_programs to `false` unless the new subsite requires program information on login.

### After deploy

* Create the new organization on appropriate environment(s).
  - Branches and programs can be managed through the Admin UI
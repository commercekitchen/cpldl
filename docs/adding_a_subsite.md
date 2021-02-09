# Adding a new Subsite

### Necessary information

- New organization name (ex/ "East Baton Rouge Public Library")
- Subdomain name (ex/ "ebrpl")
- New organization url (ex/ "https://www.ebrpl.com")
- Branch information
  - Should users select branches on login?
  - What are the available branch names
- Program information
  - Should users select programs on login?
  - What program options?
- Header logo
  - .png
  - Full Color
  - 120px x 400px max final display dimensions
- Footer logo
  - .png
  - White, Transparent
  - 80px x 320px max final display dimensions
- Google analytics ID
- Various site texts in English and Spanish
  - Banner Greeting
  - Subheader text (user dashboard)
  - (optional) Retake quiz prompt

### Prior to deploy

- [Set up the subsite styles and mixins](subsite_styles.md)

- Create google analytics javascript partial in `app/views/shared/analytics` as `_ga_new_subdomain.html.erb`. Use one of the existing GA files as a guide. Simply replace the analytics ID with the appropriate ID for the new subdomain:

  ```
  ga('create', 'new_analytics_id', 'auto', {
    userId: userGaId
  });
  ```

  NOTE: When not using Google Analytics, the partial file must still be present, but it may be left empty.

- If applicable, add google analytics home page url and datastudio link (when created) to en.yml and es.yml

  ```
  google_analytics_url:
    ...
    new_subdomain: "https://analytics.google.com/analytics/web/#embed/report-home/_ANALYTICS_HOMEPAGE_ID_/"

  google_studio_url:
    ...
    new_subdomain: "https://datastudio.google.com/open/_STUDIO_PAGE_ID_"
  ```

- Create the organization locally to test/adjust subsite styles:

  ```
  Organization.create(name: "New Library", subdomain: "new_subdomain", branches: true, accepts_programs: false)
  ```

  Notes: Set branches to `false` if subsite doesn't require branch specification on login. Set accepts_programs to `false` unless the new subsite requires program information on login.

### Deployment

To deploy a new subsite, use a [data migration](https://github.com/ilyakatz/data-migrate).

- Run `rails g data_migration create_example_subsite`

- Update the new data migration file created in `db/data` with the new subsite's information:

  ```
  class CreateExampleSubsite < ActiveRecord::Migration[5.2]
    def up
      # Subsite Attributes
      subsite_attributes = {
        name: 'New Subsite Name',
        subdomain: 'new_subdomain',
        branches: false,
        accepts_programs: false,
        accepts_partners: false
      }

      # Admin users
      admins = ['admin@example.com']

      # Create the subdomain organization
      subsite = Organization.create!(subsite_attributes)

      # Invite Admins
      admins.each do |email|
        AdminInvitationService.invite(email: email, organization: subsite)
      end

      # Custom setup for branches, partners, etc. would go here...

      # Import all subsite courses
      Course.pla.where(pub_status: 'P').each do |course|
        CourseImportService.new(organization: subsite, course_id: course.id)
      end
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
  ```

### After Deployment

- Add subsite Footer logo and logo link through subsite admin panel customization pages

- Customize subsite texts through admin panel

  - Custom banner greeting text
  - Additional banner greeting content
  - User dashboard subheader
  - Retake quiz prompt (usually just 'Retake the Quiz' unless otherwise specified)
  - Explanation of course colors (misspelled key in yaml file) - courses to be completed are displayed with the colors passed to the `course_widget` SASS mixin in the `_new_subdomain.scss` class. Completed courses are displayed in Gray by default. This sentence usually ends with the prompt "To add more to your plan,"

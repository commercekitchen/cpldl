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
  - Full Color
  - 120px x 400px max final display dimensions
- Footer logo
  - White, Transparent
  - 80px x 320px max final display dimensions
- Google analytics ID
- Various site texts in English and Spanish
  - Banner Greeting
  - Subheader text (user dashboard)
  - (optional) Retake quiz prompt

### Prior to deploy

- [Set up the subsite styles and mixins](subsite_styles.md)

- Add subsite Footer logo and logo link through subsite admin panel customization pages

- Customize subsite texts through admin panel

  - Custom banner greeting text
  - Additional banner greeting content
  - User dashboard subheader
  - Retake quiz prompt (usually just 'Retake the Quiz' unless otherwise specified)
  - (misspelled key in yaml file) Explanation of course colors - courses to be completed are displayed with the colors passed to the `course_widget` SASS mixin in the `_new_subdomain.scss` class. Completed courses are displayed in Gray by default. This sentence usually ends with the prompt "To add more to your plan,"

- Create google analytics javascript partial in `views/shared/` as `_ga_new_subdomain.html.erb`. Use one of the existing GA files as a guide. Simply replace the analytics ID with the appropriate ID for the new subdomain:

  ```
  ga('create', 'new_analytics_id', 'auto', {
    userId: userGaId
  });
  ```

- Add google analytics home page url and datastudio link (when created) to en.yml and es.yml

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

To deploy a new subsite, use a [data migration](https://github.com/ilyakatz/data-migrate) like the following example:

```
class CreateClevelandOrganization < ActiveRecord::Migration[5.2]
  def up
    # Create the subdomain organization
    cleveland = Organization.create!(name: 'Cleveland Foundation', subdomain: 'cleveland', accepts_partners: true)

    # Invite an admin user
    AdminInvitationService.invite(email: 'cwilliams@clevefdn.org', organization: cleveland)

    # Custom setup for branches, partners, etc. would go here...

    # Import all subsite courses
    Course.where(pub_status: 'P', subsite_course: true).each do |course|
      CourseImportService.new(organization: cleveland, course_id: course.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```
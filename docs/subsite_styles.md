# Customizing Subsite Styles

## Defining Colors

Create color variables in `app/assets/stylesheets/vars.scss`:

```
/* NEW_SUBDOMAIN */
$new_subdomain-blue: #2C3590;
$new_subdomain-orange: #A66401;
$new_subdomain-gray: #716C6B;
```

These colors can be named anything you like, you'll use them as variables in SASS mixins.

## Customizable components

Create a new file for the subsite styles (`assets/stylesheets/subdomains/_new_subdomain.scss`).

This file should define a single class which matches your new subdomain name, which includes 6 application component SASS mixins (see specifics below):

```
  .new_subdomain {
    @include color_scheme($primary_color, $action_color, $footer_color, $underline_color, $cms_link_color);
    @include banner( $background_color, $custom_banner_font, $slogan_alignment, $text_color);
    @include buttons($button_color, $text_color);
    @include course_widget($primary_bg_color, $secondary_bg_color);
    @include lesson_tile($bg_color, $completed_bg_color, $check_color);
    @include icons($icon_color, $check_color);
  }
```

### `color_scheme`

The main color scheme options for headings, links and colored text.

- `$primary_color`

  - Text for headings & form input labels
  - Required

    <img src="images/color_scheme/primary_color.png" alt="Primary Color Example" width="250" />

- `$action_color`

  - Color for all links
  - Required

    <img src="images/color_scheme/action_color.png" alt="Action Color Example" width="500" />

- `$footer_color`

  - Background color for footer
  - Default: `$primary_color`

    <img src="images/color_scheme/footer_color.png" alt="Footer Color Example" width="500" />

- `$underline_color`

  - Underline for some table rows. Ex/ course completion rows
  - Deafult: `$primary_color`

    <img src="images/color_scheme/underline_color.png" alt="Underline Color Example" width="500" />

- `$cms_link_color`

  - Color of cms page links in footer
  - Deafult: `$white`

    <img src="images/color_scheme/cms_link_color.png" alt="CMS Link Color Example" width="200" />

### `banner`

Banner background & text colors and font sizes (if specified)

- `$background_color`

  - Background of the main header banner
  - Required

    <img src="images/banner/background_color.png" alt="Background Color Example" width="500" />

- `$custom_banner_font`

  - Banner text font size
  - Default: `3.3em`

    <img src="images/banner/custom_banner_font.png" alt="Banner Font Size Example" width="500" />

- `$slogan_alignment`

  - Text alignment of header slogan (unauthenticated landing page)
  - Default: `left`

    <img src="images/banner/slogan_alignment.png " alt="Slogan Alignment Example" width="500" />

- `$text_color`

  - Text color in main banner
  - Default: `$white`

    <img src="images/banner/text_color.png" alt="Text Color Example" width="500" />

### `buttons`

Defines background and text color for buttons

- `$button_color`

  - Background color for buttons
  - Required

    <img src="images/buttons/button_color.png" alt="Button Color Example" width="300" />

- `$text_color`

  - Text color for buttons
  - Default: `$white`

    <img src="images/buttons/text_color.png" alt="Button Text Color Example" width="300" />

### `course_widget`

Course widget header background. Two colors are provided, and the result is a gradient between them.

- `$primary_bg_color`

  - Primary course widget header background color
  - Required

    <img src="images/course_widget/primary_bg_color.png" alt="Course Widget Primary Background Color Example" width="300" />

- `$secondary_bg_color`

  - Secondary course widget header background color
  - Default: `$primary_background`

    <img src="images/course_widget/secondary_bg_color.png" alt="Course Widget Secondary Background Color Example" width="300" />

### `lesson_tile`

Lesson widget boxes

- `$bg_color`

  - Header background color for incomplete lesson tiles
  - Required

    <img src="images/lesson_tile/bg_color.png" alt="Lesson Tile Background Color Example" width="300" />

- `$completed_bg_color`

  - Header background color for completed lesson tiles
  - Required

    <img src="images/lesson_tile/completed_bg_color.png" alt="Lesson Tile Completed Background Color Example" width="300" />

- `$check_color`

  - Color of checkmark on completed lesson tiles
  - Required

    <img src="images/lesson_tile/check_color.png" alt="Lesson Tile Check Color Example" width="300" />

### `icons`

All site icons not previously accounted for.

- `$icon_color`

  - Primary icon color for icons without a previously specified color
  - Required

    <img src="images/icons/icon_color.png" alt="Icon Color Example" width="300" />

- `$check_color`

  - Color for checkmark next to completed lessons in "lesson playlist"
  - Required

    <img src="images/icons/check_color.png" alt="Icon Check Color Example" width="400" />

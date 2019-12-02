# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.precompile += %w( admin/courses.js pdf.css )
Rails.application.config.assets.precompile += %w( *.png *.jpg *.jpeg *.gif *.svg )
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/fonts"
Rails.application.config.assets.precompile += %w( .svg .eot .woff .ttf )
Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
  Rails.application.config.assets.paths << path
end

Dir.glob("#{Rails.root}/app/assets/javascripts/**/").each do |path|
  Rails.application.config.assets.paths << path
end

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(ckeditor/*)

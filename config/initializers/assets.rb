# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( admin/courses.js )
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.svg)
Rails.application.config.assets.paths << "#{Rails.root}/app/assets/fonts"
Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
  Rails.application.config.assets.paths << path
end

Dir.glob("#{Rails.root}/app/assets/javascripts/**/").each do |path|
  Rails.application.config.assets.paths << path
end
# Rails.application.config.assets.paths << Rails.root.join("app", "assets", "images")

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

gem 'rails', '~> 7.0.4.2'
gem 'pg'
gem 'puma'
gem 'sass-rails'
gem 'webpacker'
gem 'turbolinks'
gem 'jbuilder'

gem 'bootsnap', require: false
gem 'rexml'

gem 'bulma-extensions-rails'
gem 'devise'

gem 'omniauth'
gem 'omniauth-facebook'

gem 'faker'
gem 'kaminari'

gem 'stripe'

gem 'trestle'
gem 'trestle-auth'
gem 'trestle-search'
gem 'trestle-tinymce'
gem 'activemerchant'
gem 'devise_lastseenable'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "omniauth-rails_csrf_protection"
gem 'codecov', :require => false, :group => :test
gem "aws-sdk-s3", require: false
gem "dockerfile-rails", ">= 1.2", :group => :development

gem "redis", "~> 5.0"

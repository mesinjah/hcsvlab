source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem "therubyracer"
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem "jquery-rails", "2.3.0"
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
    


group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  # cucumber gems
  gem "cucumber"
  gem "capybara"
  gem "database_cleaner"
  #gem "spork"
  gem "launchy"    # So you can do Then show me the page
end

group :development do
  gem 'xray-rails'
  gem 'pry'
  gem 'pry-rails'
  gem 'zeus'
  gem 'newrelic_rpm'

  # Deployment tracker
  gem "create_deployment_record", git: 'https://github.com/IntersectAustralia/create_deployment_record.git'
end

group :test do
  gem "cucumber-rails", :require => false
  gem "shoulda"
  gem "brakeman"
  gem "simplecov", ">=0.3.8", :require => false
  gem 'simplecov-rcov'
  gem "poltergeist"
  gem "selenium-webdriver"
  gem 'spreewald'
end

gem "jsonpath"

gem 'zeroclipboard-rails'
gem "haml"
gem "haml-rails"
# gem "bootstrap-sass"
gem "simple_form"
gem "devise"
gem "email_spec", :group => :test
gem "cancan"


# blacklight and hydra gems
gem 'blacklight'
gem 'hydra-head', "~>6.0.0"
gem 'jettywrapper'

gem "bootstrap-sass"
gem 'activerecord-tableless'

gem 'stomp'
gem 'celluloid'
gem 'daemons'
gem 'activemessaging'

gem 'solrizer'
# gem 'solrizer-fedora', "3.0.0.pre1"
gem 'rsolr'
gem "xml-simple"
gem 'nokogiri'
gem 'fileutils'
gem 'mimemagic'
# gem for showing tabs on pages
gem "tabs_on_rails"
gem 'colorize'

# ruby json builder
gem 'rabl'

# exception tracker
gem 'whoops_rails_logger', git: 'https://github.com/IntersectAustralia/whoops_rails_logger.git'

gem 'linkeddata', '~> 1.0.0'
gem 'rdf-turtle'
gem 'rdf-sesame', git: 'https://github.com/ruby-rdf/rdf-sesame.git'
gem 'json_pure', '1.8.0'
gem 'json-ld'
gem 'sparql'

gem 'request_exception_handler'

# Capistrano stuff
gem 'rvm-capistrano'
# gem "capistrano-ext"
# gem "capistrano"
gem "capistrano_colors"

gem 'tinymce-rails'
gem 'rubyzip', '0.9.9'
gem 'bagit'

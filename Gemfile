source 'http://rubygems.org'

gem 'activesupport', '>= 3.1.1'
gem 'rack',          '~> 1.4.1'
gem 'eventmachine',  '1.0.0.beta.4'
gem 'thor',          '~> 0.14.6'

group :test do
  gem 'http_router'
  gem 'turn'
  gem 'minitest'
end

group :example do
  gem 'activerecord', '3.1.1'
  gem 'mysql2', '0.2.11'

  gem 'em-http-request'

  gem 'thin', '~> 1.2.11'

  gem 'yajl-ruby', :require => 'yajl'

  gem 'http_router'
  gem 'erubis'

  gem 'async-rack'
  gem 'async_sinatra'

  platforms :mri_19 do
    gem 'rainbows'
    gem "ruby-debug19", :require => "ruby-debug" unless RUBY_VERSION > "1.9.2"
    gem 'em-synchrony'
  end

  platforms :rbx do
    # gem 'em-synchrony'
  end
end

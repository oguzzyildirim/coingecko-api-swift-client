source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Core dependencies
gem 'fastlane', '~> 2.219'

# PR Review automation
gem 'danger', '~> 9.4'
gem 'danger-swiftlint', '~> 0.37.2'

# Development dependencies
group :development do
  gem 'rubocop', '~> 1.60'  # Ruby linting
end

# Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'Fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
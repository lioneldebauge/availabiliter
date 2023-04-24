require "date"
require_relative "../lib/availabiliter"

desc "Run the tests against all ruby versions"
task :test_ruby_versions do
  authorized_versions = ["3.2.2", "3.1.4", "3.0.6", "2.7.8", "2.7.2"]

  authorized_versions.each do |version|
    print "---------RUNNING TEST FOR RUBY #{version}---------"
    system("export RBENV_VERSION=#{version} && bundle install && bundle exec rspec --fail-fast --format progress && export RBENV_VERSION=")
    print "--------------------------------------------------"
  end
end

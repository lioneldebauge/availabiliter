# frozen_string_literal: true

require_relative "lib/availabiliter/version"

Gem::Specification.new do |spec|
  spec.name          = "availabiliter"
  spec.version       = Availabiliter::VERSION
  spec.authors       = ["lioneldebauge"]
  spec.email         = ["lionel@livecolonies.com"]

  spec.summary       = "Availabiliter calculates availabilities for ruby ranges within a given time frame."
  spec.homepage      = "https://github.com/lioneldebauge/availabiliter.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.2")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lioneldebauge/availabiliter.git"
  spec.metadata["changelog_uri"] = "https://github.com/lioneldebauge/availabiliter/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 6.1.3.2"
  spec.add_development_dependency "byebug", "~> 11.1.3"
  spec.add_development_dependency "rake", "~> 13.0.3"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.16.1"
end

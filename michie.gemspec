lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "michie/version"

Gem::Specification.new do |spec|
  spec.name          = "michie"
  spec.version       = Michie::VERSION
  spec.authors       = ["Chris Salzberg"]
  spec.email         = ["chris@dejimata.com"]

  spec.summary       = %q{Memoization done right.}
  spec.description   = %q{Michie allows you to memoize methods simply by defining them in a block.}
  spec.homepage      = "https://github.com/shioyama/michie"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shioyama/michie"
  spec.metadata["changelog_uri"] = "https://github.com/shioyama/blob/master/CHANGELOG.md"

  spec.files        = Dir['{lib/**/*,[A-Z]*}']
  spec.require_paths = ['lib']

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end


lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ynaby/version"

Gem::Specification.new do |spec|
  spec.name          = "ynaby"
  spec.version       = Ynaby::VERSION
  spec.authors       = ["Rafael Millán"]
  spec.email         = ["rafmillan@gmail.com"]

  spec.summary       = %q{A Ruby library for editing YNAB transaction.}
  spec.homepage      = "https://github.com/rafaelmillan/ynaby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ynab", "~> 0.7.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.4.2"
  spec.add_development_dependency "vcr", "~> 4.0.0"
end

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_emitter/version'

Gem::Specification.new do |gem|
  gem.name          = "event_emitter-with-instance-listener"
  gem.version       = EventEmitter::VERSION
  gem.authors       = ["Sho Hashimoto", "Trey Grffith"]
  gem.email         = ["hashimoto@shokai.org", "trey.griffith@gmail.com"]
  gem.description   = %q{Ruby port of EventEmitter from Node.js}
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/).reject{|i| i=="Gemfile.lock" }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "bundler", "~> 1.3"
end

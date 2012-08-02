+# encoding: UTF-8
require File.expand_path('../lib/wamqg/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = %q{wamqg}
  gem.authors     = ["Arthur Andersen", "Franz Kißig"]
  gem.homepage    = "http://github.com/leoc/wamqg"
  gem.summary     = %q{AMQP-Websocket-Gateway}
  gem.description = %q{AMQP-Websocket-Gateway}

  gem.files         = `git ls-files`.split($\)
#  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wamqg"
  gem.require_paths = ["lib"]
  gem.version       = Wamqg::VERSION#

  gem.add_dependency "railties"
end

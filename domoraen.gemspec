lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "domoraen"
  spec.version       = File.read(File.dirname(__FILE__) + '/VERSION')
  spec.authors       = ["tily"]
  spec.email         = ["tidnlyam@gmail.com"]

  spec.summary       = %q{猫型マルコフロボット}
  spec.description   = %q{猫型マルコフロボット}
  spec.homepage      = "https://github.com/tily/domoraen"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "earthquake"
  spec.add_dependency "daemon-spawn" #, :require => "daemon_spawn"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "json"
  spec.add_dependency "sinatra"
  spec.add_dependency "ruboty"
  spec.add_dependency "ruboty-twitter"
  spec.add_dependency 'httparty'

  spec.add_development_dependency "rspec", "~> 2.8.0"
  spec.add_development_dependency "rdoc", "~> 3.12"
  spec.add_development_dependency "bundler", "~> 1.0"
  spec.add_development_dependency "simplecov", ">= 0"
end

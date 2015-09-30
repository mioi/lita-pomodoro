Gem::Specification.new do |spec|
  spec.name          = "lita-pomodoro"
  spec.version       = "0.1.0"
  spec.authors       = ["Mioi Hanaoka"]
  spec.email         = ["mioi@mioi.net"]
  spec.description   = "Get lita to keep track of Pomodoros, the popular time management system."
  spec.summary       = "This is a Lita handler that the popular chat bot can use to keep track of your team members' pomodoro sessions."
  spec.homepage      = "http://www.github.com/mioi/lita-pomodoro"
  spec.license       = "GPL"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.6"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end

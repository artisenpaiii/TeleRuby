Gem::Specification.new do |spec|
  spec.name          = "TeleRuby"
  spec.version       = "0.1.0"
  spec.authors       = ["Bryan Sigaran"]
  spec.email         = ["bryanohss@gmail.com"]
  spec.summary       = "A lightweight HTTP server framework for Ruby"
  spec.description   = "An HTTP server framework similar to FastAPI, featuring async processing, dynamic routing, and type validation."
  spec.homepage      = "https://github.com/artisenpaiii/TeleRuby"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "puma", "~> 6.0"
  spec.add_runtime_dependency "rack", "~> 2.0"
  spec.add_runtime_dependency "json", "~> 2.0"
end

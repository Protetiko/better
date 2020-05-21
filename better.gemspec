lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "better/version"

Gem::Specification.new do |spec|
  spec.name          = "better"
  spec.version       = Better::VERSION
  spec.authors       = ["David Sennerlöv"]
  spec.email         = ["david@protetiko.com"]

  spec.summary       = %q{Better is a library of Better Ruby utils}
  spec.description   = %q{Ever needed to use that one gem that implemented a feature you needed, but only needed a small part of that gem and got a big bloated mess? Ever tried the read the code of some favorite gem and just got overwhelmed by it's shear number of files and spagetti dependency? Then Better is for You!}
  spec.homepage      = "https://github.com/Protetiko/better"

  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Protetiko/better"
  spec.metadata["changelog_uri"] = "https://github.com/Protetiko/better/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

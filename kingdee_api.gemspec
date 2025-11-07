# frozen_string_literal: true

require_relative "lib/kingdee_api/version"

Gem::Specification.new do |spec|
  spec.name = "kingdee_api"
  spec.version = KingdeeApi::VERSION
  spec.authors = ["钟声"]
  spec.email = ["444133866@qq.com"]

  spec.summary = "Authenticated HTTP client for the Kingdee Cloud API."
  spec.description = "A lightweight, modular Ruby client that signs and sends HTTP requests to the Kingdee Cloud (Jingdian) open platform."
  spec.homepage = "https://github.com/zhongsheng/kingdee_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zhongsheng/kingdee_api"
  spec.metadata["changelog_uri"] = "https://github.com/zhongsheng/kingdee_api/blob/main/CHANGELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end

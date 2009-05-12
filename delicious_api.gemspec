# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delicious_api}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Javier Blanco Gutierrez"]
  s.date = %q{2009-05-05}
  s.default_executable = %q{delicious_api}
  s.description = %q{delicious_api is a pure Ruby client for the "Delicious API" (http://delicious.com/help/api). It provides an easy
  way to read/write bookmarks, tags and bundles to Delicious accounts.}
  s.email = %q{jbgutierrez@gmail.com}
  s.files = ["README.textile", "delicious_api.gemspec", "lib/delicious_api.rb", "lib/delicious_api/base.rb", "lib/delicious_api/bookmark.rb", "lib/delicious_api/bundle.rb", "lib/delicious_api/extensions.rb", "lib/delicious_api/extensions/hash.rb", "lib/delicious_api/tag.rb", "lib/delicious_api/wrapper.rb", "spec/custom_macros.rb", "spec/custom_matchers.rb", "spec/delicious_api_spec.rb", "spec/delicious_api_spec/base_spec.rb", "spec/delicious_api_spec/bookmark_spec.rb", "spec/delicious_api_spec/bundle_spec.rb", "spec/delicious_api_spec/tag_spec.rb", "spec/delicious_api_spec/wrapper_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jbgutierrez/delicious_api}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{delicious_api is a pure Ruby client for the "Delicious API" (http://delicious.com/help/api). It provides an easy
  way to read/write bookmarks, tags and bundles to Delicious accounts.}
  s.test_files = ["spec/delicious_api_spec.rb", "spec/delicious_api_spec/base_spec.rb", "spec/delicious_api_spec/bookmark_spec.rb", "spec/delicious_api_spec/bundle_spec.rb", "spec/delicious_api_spec/tag_spec.rb", "spec/delicious_api_spec/wrapper_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    s.add_dependency('activesupport', '>= 2.3.2')
    s.add_dependency('hpricot', '>= 0.8.1')
    s.add_dependency('rspec', '>= 1.2.6')
  end
end

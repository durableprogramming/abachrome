# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create do |t|

  t.test_prelude = %(require "simplecov"; SimpleCov.start { add_filter %p }) % ['/test/']
  t.test_globs = FileList["test/**/*_test.rb", 'test/**/test_*.rb']
  t.framework = %(require "test/test_helper.rb")
end


task default: :test


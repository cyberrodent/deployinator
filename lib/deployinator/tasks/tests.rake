#
# Tests
#

namespace :deployinator do
  namespace :test do

    desc 'Run all the tests'
    Rake::TestTask.new :all do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.pattern = "#{File.dirname(__FILE__)}/../../../test/**/*_test.rb"
      t.verbose = false
    end

    desc 'Run deployinator unit tests'
    Rake::TestTask.new :unit do |t|
      t.libs << 'lib'
      t.pattern = "#{File.dirname(__FILE__)}/../../../test/unit/**/*_test.rb"
      t.verbose = false
    end

    desc 'Run deployinator functional tests'
    Rake::TestTask.new :functional do |t|
      t.libs << 'lib'
      # we've secretly put a stacks directory inside our test dir 
      # This lets us load stacks from 'test/stacks'
      t.libs << 'test'
      t.pattern = "#{File.dirname(__FILE__)}/../../../test/functional/**/*_test.rb"
      t.verbose = false
    end
  end
end

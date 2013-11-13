require 'minitest/spec'
require 'minitest/autorun'
require 'push_package'

def fixture_path(*paths)
  File.join(File.dirname(__FILE__), 'fixtures', *paths)
end

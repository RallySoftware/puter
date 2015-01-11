require 'rspec'
require 'rspec/its'
require_relative '../lib/puter'

#was thinking VMonkey could be mocked, but would need to return RbvMomi stuff, unsure what to do here
class MockVMonkey
  #mock vmonkey call here, but they return RbvMomi things, eg - would have to mock what Rbvmomi returns, sigh
end

RSpec.configure do |c|
  c.formatter = :documentation
  c.color = true
end

class String
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

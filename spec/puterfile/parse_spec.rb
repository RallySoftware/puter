require 'spec_helper'
require 'puter/puterfile'

describe Puter::Puterfile do
  describe '#parse' do
    context 'with a simple Puterfile' do
      subject do
        Puter::Puterfile.parse(<<-EOF.gsub /^\s+/, ""
          FROM scratch

          # comment
          RUN echo foo
          ADD afile

          EOF
        )
      end

      its(:raw) { should =~ /afile/ }
      its(:lines) { should include 'RUN echo foo' }
      its(:from) { should == 'scratch' }
    end
  end
end

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
      # its(:from) { should == 'scratch' }
      # specify { subject.line[0].should be_from }
      # specify { subject.line[1].should be_blank }
      # specify { subject.line[2].should be_comment }
      # specify { subject.line[3].should be_run }
      # specify { subject.line[4].should be_add }
    end
  end
end

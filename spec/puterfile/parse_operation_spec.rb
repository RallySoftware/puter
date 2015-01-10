require 'spec_helper'
require 'puter/puterfile'

describe Puter::Puterfile do
  describe '#parse_operation' do
    context 'should raise a syntax error on' do
      specify('a nil line')                            { expect { Puter::Puterfile.parse_operation(nil)     }.to raise_error Puter::SyntaxError }
      specify('an unknown command')                    { expect { Puter::Puterfile.parse_operation('BLAH')  }.to raise_error Puter::SyntaxError }
      specify('non-blank line without a continuation') { expect { Puter::Puterfile.parse_operation(' BLAH') }.to raise_error Puter::SyntaxError }
      specify('a command line without data')           { expect { Puter::Puterfile.parse_operation('FROM')  }.to raise_error Puter::SyntaxError }
    end

    context 'empty line' do
      subject { Puter::Puterfile.parse_operation("") }
      specify { subject[:operation].should == Puter::Puterfile::BLANK }
    end

    context 'whitspace only line' do
      subject { Puter::Puterfile.parse_operation(" \t ") }
      specify { subject[:operation].should == Puter::Puterfile::BLANK }
    end

    context 'comment line' do
      subject { Puter::Puterfile.parse_operation('# a comment') }
      specify { subject[:operation].should == Puter::Puterfile::COMMENT }
      specify { subject[:data].should == '# a comment' }
    end

    context 'comment line starting with whitespace' do
      subject { Puter::Puterfile.parse_operation('  # a comment') }
      specify { subject[:operation].should == Puter::Puterfile::COMMENT }
      specify { subject[:data].should == '  # a comment' }
    end

    context 'comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  # a comment', "  \\") }
      specify { subject[:operation].should == Puter::Puterfile::COMMENT }
      specify { subject[:data].should == '  # a comment' }
    end

    context 'non-comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  more', "  \\") }
      specify { subject[:operation].should == Puter::Puterfile::CONTINUE }
      specify { subject[:data].should == '  more' }
    end

    context 'FROM' do
      subject { Puter::Puterfile.parse_operation('FROM  blah') }
      specify { subject[:operation].should == Puter::Puterfile::FROM }
      specify { subject[:data].should == 'blah' }
    end
  end

  describe '#parse_operations' do
    context 'with a simple Puterfile' do
      subject do
        puterfile = <<-EOF
          FROM scratch

          # comment
          RUN echo foo
          ADD afile

          RUN continuation \
              # comment line in a continuation \
              next line \
              last line

          EOF
        indent = puterfile[/^\s+/].length
        Puter::Puterfile.parse puterfile.gsub(/^\s+{#{indent}}/, "").split("\n")
      end

      it { puts subject.operations.inspect }
      # specify { subject.operations[0][:operation].should == Puter::Puterfile::FROM }
      # specify { subject.operations[1][:operation].should == Puter::Puterfile::BLANK }
      # specify { subject.operations[2][:operation].should == Puter::Puterfile::COMMENT }
      # specify { subject.operations[3][:operation].should == Puter::Puterfile::RUN }
      # specify { subject.operations[4][:operation].should == Puter::Puterfile::COMMENT }
      # specify { subject.operations[5][:operation].should == Puter::Puterfile::CONTINUE }
      # specify { subject.operations[6][:operation].should == Puter::Puterfile::CONTINUE }
      # specify { subject.operations[7][:operation].should == Puter::Puterfile::BLANK }

    end
  end
end
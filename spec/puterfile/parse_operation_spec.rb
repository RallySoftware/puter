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
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::BLANK) }
    end

    context 'whitspace only line' do
      subject { Puter::Puterfile.parse_operation(" \t ") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::BLANK) }
    end

    context 'comment line' do
      subject { Puter::Puterfile.parse_operation('# a comment') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('# a comment') }
    end

    context 'comment line starting with whitespace' do
      subject { Puter::Puterfile.parse_operation('  # a comment') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('  # a comment') }
    end

    context 'comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  # a comment', "  \\") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('  # a comment') }
    end

    context 'non-comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  more', "  \\") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::CONTINUE) }
      specify { expect(subject[:data]).to eq('  more') }
    end

    context 'FROM' do
      subject { Puter::Puterfile.parse_operation('FROM  blah') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::FROM) }
      specify { expect(subject[:data]).to eq('blah') }
    end
  end

  describe '#parse_operations' do
    context 'with a simple Puterfile' do
      subject do
        Puter::Puterfile.parse <<-EOF.unindent
          FROM scratch

          # comment
          RUN echo foo
          ADD afile

          RUN continuation \\
              # comment line in a continuation \\
              next line \\
              last line
          EOF
      end

      specify { expect(subject.operations[0][:operation]).to eq(Puter::Puterfile::FROM) }
      specify { expect(subject.operations[1][:operation]).to eq(Puter::Puterfile::BLANK) }
      specify { expect(subject.operations[2][:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject.operations[3][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.operations[4][:operation]).to eq(Puter::Puterfile::ADD) }
      specify { expect(subject.operations[5][:operation]).to eq(Puter::Puterfile::BLANK) }
      specify { expect(subject.operations[6][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.operations[7][:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject.operations[8][:operation]).to eq(Puter::Puterfile::CONTINUE) }
      specify { expect(subject.operations[9][:operation]).to eq(Puter::Puterfile::CONTINUE) }
    end

    context 'should raise a syntax error with a line number' do
      subject do
        begin
          Puter::Puterfile.parse <<-EOF.unindent
            FROM scratch
            XXX
            EOF
          rescue Puter::SyntaxError => e
            return e
          end
      end

      its(:message) { should match /line 2/ }
    end

    context 'when the first line is not a FROM command' do
      specify { expect { Puter::Puterfile.parse_operations(['# not a FROM']) }.to raise_error Puter::SyntaxError }
    end

    context 'when the Puterfile is empty' do
      specify { expect { Puter::Puterfile.parse_operations([]) }.to raise_error Puter::SyntaxError }
    end

    context 'when the Puterfile is whitespace only' do
      specify { expect { Puter::Puterfile.parse_operations(['  ']) }.to raise_error Puter::SyntaxError }
    end
  end
end
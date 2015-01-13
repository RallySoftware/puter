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
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'whitspace only line' do
      subject { Puter::Puterfile.parse_operation(" \t ") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::BLANK) }
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'comment line' do
      subject { Puter::Puterfile.parse_operation('# a comment') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('# a comment') }
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'comment line starting with whitespace' do
      subject { Puter::Puterfile.parse_operation('  # a comment') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('  # a comment') }
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  # a comment', "  \\") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject[:data]).to eq('  # a comment') }
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'non-comment line after a continuation line' do
      subject { Puter::Puterfile.parse_operation('  more', "  \\") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::CONTINUE) }
      specify { expect(subject[:data]).to eq('more') }
      specify { expect(subject[:continue]).to be_falsey }
    end

    context 'line with a continuation' do
      subject { Puter::Puterfile.parse_operation("RUN echo hello \\") }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject[:data]).to eq('echo hello  ') }
      specify { expect(subject[:continue]).to be_truthy }
    end

    context 'FROM' do
      subject { Puter::Puterfile.parse_operation('FROM  blah') }
      specify { expect(subject[:operation]).to eq(Puter::Puterfile::FROM) }
      specify { expect(subject[:data]).to eq('blah') }
      specify { expect(subject[:continue]).to be_falsey }
    end
  end

  describe '#parse_operations' do
    context 'with a simple Puterfile' do
      subject do
        Puter::Puterfile.parse <<-EOF.unindent
          FROM scratch

          # comment
          RUN echo foo
          ADD afile tofile

          RUN yum install \\
              # comment line in a continuation \\
              package1 \\
              package2

          ADD https://really/long/url/foo.tar.gz \\
              /tmp/foo.tar.gz
          EOF
      end

      specify { expect(subject.operations[0][:operation]).to eq(Puter::Puterfile::FROM) }
      specify { expect(subject.operations[1][:operation]).to eq(Puter::Puterfile::BLANK) }
      specify { expect(subject.operations[2][:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject.operations[3][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.operations[4][:operation]).to eq(Puter::Puterfile::ADD) }
      specify { expect(subject.operations[5][:operation]).to eq(Puter::Puterfile::BLANK) }
      specify { expect(subject.operations[6][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.operations[6][:data]).to eq('yum install  ') }
      specify { expect(subject.operations[6][:continue]).to be_truthy }
      specify { expect(subject.operations[7][:operation]).to eq(Puter::Puterfile::COMMENT) }
      specify { expect(subject.operations[8][:operation]).to eq(Puter::Puterfile::CONTINUE) }
      specify { expect(subject.operations[8][:data]).to eq('package1  ') }
      specify { expect(subject.operations[8][:continue]).to be_truthy }
      specify { expect(subject.operations[9][:operation]).to eq(Puter::Puterfile::CONTINUE) }

      specify { expect(subject.executable_ops.length).to eq(4) }
      specify { expect(subject.executable_ops[0][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.executable_ops[0][:data]).to match(/echo foo/) }
      specify { expect(subject.executable_ops[0][:start_line]).to eq(3) }
      specify { expect(subject.executable_ops[0][:end_line]).to eq(3) }

      specify { expect(subject.executable_ops[1][:operation]).to eq(Puter::Puterfile::ADD) }
      specify { expect(subject.executable_ops[1][:data]).to match(/afile/) }
      specify { expect(subject.executable_ops[1][:start_line]).to eq(4) }
      specify { expect(subject.executable_ops[1][:end_line]).to eq(4) }

      specify { expect(subject.executable_ops[2][:operation]).to eq(Puter::Puterfile::RUN) }
      specify { expect(subject.executable_ops[2][:data]).to match(/yum install\s+package1\s+package2/) }
      specify { expect(subject.executable_ops[2][:start_line]).to eq(6) }
      specify { expect(subject.executable_ops[2][:end_line]).to eq(9) }

      specify { expect(subject.executable_ops[3][:operation]).to eq(Puter::Puterfile::ADD) }
      specify { expect(subject.executable_ops[3][:from]).to eq('https://really/long/url/foo.tar.gz') }
      specify { expect(subject.executable_ops[3][:to]).to eq('/tmp/foo.tar.gz') }
      specify { expect(subject.executable_ops[3][:start_line]).to eq(11) }
      specify { expect(subject.executable_ops[3][:end_line]).to eq(12) }
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

    context 'should raise a syntax error when ADD operation lacks two parameters' do
      specify { expect { Puter::Puterfile.parse("FROM foo\nADD just_one\n") }.to raise_error Puter::SyntaxError }
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

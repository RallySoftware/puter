module Puter
  class SyntaxError < Exception
    attr_accessor :line
  end

  class Puterfile

    attr_accessor :raw
    attr_accessor :lines
    attr_accessor :from
    attr_accessor :operations
    attr_accessor :executable_ops

    BACKSLASH = "\\"

    FROM     = :from
    RUN      = :run
    ADD      = :add
    BLANK    = :blank
    CONTINUE = :continue
    COMMENT  = :comment

    COMMANDS = [ FROM, RUN, ADD ]

    class << self
      def from_path(path)
        parse File.open(path, 'rb') { |f| f.read }
      end

      def parse(raw)
        p = Puterfile.new
        p.raw = raw
        p.lines = raw.to_s.split "\n"
        p.operations = parse_operations(p.lines)
        p.executable_ops = executable_operations(p.operations)
        p.from = p.operations[0][:data]
        p
      end

      def parse_operations(lines)
        raise Puter::SyntaxError.new "File is empty.  First line must be a FROM command" if lines.length == 0

        ops = []
        previous_line = ""
        lines.each_with_index do | line, i |
          begin
            ops << parse_operation(line, previous_line)
            if i == 0
              raise Puter::SyntaxError.new "First line must be a FROM command" unless ops[i][:operation] == FROM
            end
          rescue Puter::SyntaxError => se
            raise Puter::SyntaxError.new "On line #{i+1}: #{se.message}"
          end
          previous_line = line
        end
        ops
      end

      def parse_operation(line, previous_line="")
        op = {}
        line = line.rstrip unless line.nil?

        case
        when line.nil?
          raise SyntaxError.new 'cannot parse nil lines'

        # blank line
        when line.strip.empty?
          op[:operation] = BLANK
          op[:data]      = line
          op[:continue]  = false

        # commented line
        when line =~ /\s*\#/
          op[:operation] = COMMENT
          op[:data]      = line
          op[:continue]  = line[-1] == BACKSLASH

        # continuation of a previous line
        when line =~ /\s/ && previous_line.rstrip[-1] == BACKSLASH
          op[:operation] = CONTINUE
          op[:data]      = line.lstrip
          op[:continue]  = line[-1] == BACKSLASH

        # must be an operation (FROM, ADD, RUN, ...)
        else
          parts = line.split(/\s+/, 2)
          cmd = parts[0].downcase.to_sym
          data = parts[1]

          raise SyntaxError.new "Unknown operation [#{cmd.to_s.upcase}]" unless COMMANDS.include? cmd
          raise SyntaxError.new "Operation [#{cmd.to_s.upcase}] has no data" if data.nil?
          op[:operation] = cmd
          op[:data]      = data
          op[:continue]  = line[-1] == BACKSLASH

        end
        op[:data][-1] = " " if op[:continue]

        op
      end

      def executable_operations(operations)
        execs = []
        operations.each_with_index do |op, i|
          case op[:operation]
          when ADD, RUN
            exec = {
              :operation => op[:operation],
              :data      => op[:data].dup
            }
            exec[:start_line] = i
            exec[:end_line] = i
            execs << exec
          when CONTINUE
            execs.last[:data] << op[:data]
            execs.last[:end_line] = i
          end
        end
        execs
      end

    end

  end

end

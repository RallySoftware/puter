module Puter
  class SyntaxError < Exception
  end

  class Puterfile
    FROM     = :from
    RUN      = :run
    ADD      = :add
    BLANK    = :blank
    CONTINUE = :continue
    COMMENT  = :comment

    COMMANDS = [ FROM, RUN, ADD ]

    class << self
      def from_path(path)
        stuff = ReadFrom(path)

        parse(stuff)
      end

      def parse(raw)
        p = Puterfile.new
        p.raw = raw
        p.lines = raw.to_s.split "\n"
        p.operations = parse_operations(p.lines)
        p.from = 'balls'
        p
      end

      def parse_operations(lines)
        ops = []
        previous_line = ""
        lines.each do | line |
          ops << parse_operation(line, previous_line)
          previous_line = line
        end
        ops
      end

      def parse_operation(line, previous_line="")
        op = {}

        case
        when line.nil?
          raise SyntaxError.new 'cannot parse nil lines'

        # blank line
        when line.strip.empty?
          op[:operation] = BLANK
          op[:data]      = line


        # commented line
        when line =~ /\s*\#/
          op[:operation] = COMMENT
          op[:data]      = line


        # continuation of a previous line
        when line =~ /\s/ && previous_line.strip[-1] == "\\"
          op[:operation] = CONTINUE
          op[:data]      = line

        # must be an operation (FROM, ADD, RUN, ...)
        else
          parts = line.split(/\s+/, 2)
          cmd = parts[0].downcase.to_sym
          data = parts[1]

          raise SyntaxError.new "Unknown operation [#{cmd.to_s.upcase}]" unless COMMANDS.include? cmd
          raise SyntaxError.new "Operation [#{cmd.to_s.upcase}] has no data" if data.nil?
          op[:operation] = cmd
          op[:data]      = data

        end
        op
      end

    end

    attr_accessor :raw
    attr_accessor :lines
    attr_accessor :from
    attr_accessor :operations

  end

end

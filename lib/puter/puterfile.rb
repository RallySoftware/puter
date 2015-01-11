module Puter
  class SyntaxError < Exception
    attr_accessor :line
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
        parse File.open(path, 'rb') { |f| f.read }
      end

      def parse(raw)
        p = Puterfile.new
        p.raw = raw
        p.lines = raw.to_s.split "\n"
        p.operations = parse_operations(p.lines)
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

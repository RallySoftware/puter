module Puter
  class SyntaxError < Exception
  end

  class RunError < Exception
    attr_accessor :result
    def initialize(message, result)
      super(message)
      @result = result
    end
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
            exec[:start_line] = exec[:end_line] = i
            execs << exec
          when CONTINUE
            execs.last[:data] << op[:data]
            execs.last[:end_line] = i
          end
        end

        execs.select { |e| e[:operation] == ADD }.each do |e|
          e[:from], e[:to] = e[:data].strip.split /\s+/, 2
          raise SyntaxError.new "ADD operation requires two parameters #{e.inspect}" if e[:from].nil? || e[:to].nil?
        end

        execs
      end

    end

    def apply(context, backend, ui)
      dependency_check(context)
      ret = { :exit_status => 0, :exit_signal => nil }

      executable_ops.each do |op|
        case op[:operation]
        when ADD
          backend.add path_in_context(op[:from], context), op[:to]
        when RUN
          ret = backend.run op[:data] do | type, data |
            case type
            when :stderr
              ui.error data
            when :stdout
              ui.info data
            end
          end

          if ret[:exit_status] != 0
            line = "#{op[:start_line]+1}"
            plural = ""
            if op[:start_line] != op[:end_line]
              line << "..#{op[:end_line]+1}"
              plural = "s"
            end

            raise RunError.new "On line#{plural} #{line}: RUN command exited non-zero.", ret
          end
        end
      end

      ret
    end

    private
    def path_in_context(path, context)
      File.expand_path(path, context)
    end

    def dependency_check(context)
      executable_ops.each do |op|
        case op[:operation]
        when ADD
          File.open(path_in_context(op[:from], context), 'r') {}
        end
      end
    end

  end

end

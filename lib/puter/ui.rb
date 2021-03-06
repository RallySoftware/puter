module Puter
  module UI
    def info(message, color = :bold)
      say(message, color)
    end

    def warn(message, color = :yellow)
      say(message, color)
    end

    def error(message, color = :red)
      say(message, color)
    end

    def remote_stdout(message, color = :white)
      say(message, color)
    end

    def remote_stderr(message, color = :orange)
      say(message, color)
    end

  end
end
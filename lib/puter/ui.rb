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
  end
end
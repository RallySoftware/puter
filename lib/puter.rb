require 'thor'

module Puter
  autoload :CLI, 'puter/cli'
  autoload :UI,  'puter/ui'

  Thor::Base.shell.send(:include, Puter::UI)

  class << self
    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end

    def executable_name
      File.basename($PROGRAM_NAME)
    end

    def ui
      @ui ||= Thor::Base.shell.new
    end
  end
end


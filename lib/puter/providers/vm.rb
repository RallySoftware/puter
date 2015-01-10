require 'vmonkey'

module Puter
  module Provider
    class Vm

      def vmonkey
        @vmonkey ||= VMonkey.connect
      end

      def images(path)
        vmonkey.folder!(path).templates.collect(&:name)
      end

      def rmi(path)
        vmonkey.template!(path).destroy
      end

      def rm(path)
        vmonkey.vm!(path).destroy
      end

    end
  end
end
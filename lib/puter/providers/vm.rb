require 'vmonkey'
require 'puter/puterfile'

module Puter
  module Provider
    class Vm

      def images(path)
        vmonkey.folder!(path).templates.collect(&:name)
      end

      def host(name, &block)
        target = vmonkey.vm! name
        block.call(target.guest_ip)
      end

      def build(name, template_name, opts, &block)
        template = vmonkey.vm! template_name
        if opts[:force]
          target = template.clone_to! name
        else
          target = template.clone_to name
        end

        target.start
        target.wait_for_port 22
        block.call(target.guest_ip)
        target.stop
        target.MarkAsTemplate()
      end

      def rmi(path)
        vmonkey.template!(path).destroy
      end

      def rm(path)
        vmonkey.vm!(path).destroy
      end

      def vmonkey
        @vmonkey ||= VMonkey.connect
      end

    end
  end
end

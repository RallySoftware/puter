require 'vmonkey'
require 'puter/puterfile'

module Puter
  module Provider
    class Vm

      def initialize(logger)
        @logger = logger
      end

      def images(path)
        vmonkey.folder!(path).templates.collect(&:name)
      end

      def host(name, &block)
        target = vmonkey.vm! name
        block.call(target.guest_ip)
      end

      def build(name, context, templates_path, puterfile)
        @logger.info "would build here: [#{name}, #{context}, #{templates_path}, #{puterfile.from}]"
      end

      def rmi(path)
        vmonkey.template!(path).destroy
      end

      def rm(path)
        vmonkey.vm!(path).destroy
      end

      private

      def do_puterfile(vm, context, puterfile)
        puterfile.executable_ops.each do |op|
          case op[:operation]
          when Puter::Puterfile::RUN
            @logger.info "I would RUN (#{op[:start_line]}, #{op[:end_line]}): #{op[:operation]} #{op[:data]}"
          when Puter::Puterfile::ADD
            @logger.info "I would ADD (#{op[:start_line]}, #{op[:end_line]}): #{op[:operation]} #{op[:from]} TO #{op[:to]}"
          end
        end
      end

      def vmonkey
        @vmonkey ||= VMonkey.connect
      end

    end
  end
end

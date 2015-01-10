require 'puter/providers/vm'

module Puter
  module CLI
    class Vm < Thor
      desc 'images', 'Lists available puter images.'
      long_desc <<-LONGDESC
        Lists available puter images.

        With --templates option, lists images found in the given vSphere folder.
      LONGDESC
      option :templates, :type => :string, :default => '/Templates', :banner => '/path/to/puter/templates'
      def images(templates_path = options[:templates])
        CLI.run_cli do
          vm.images(templates_path).each { |i| Puter.ui.info i }
        end
      end

      desc "rmi NAME", "Removes (deletes) a puter image."
      long_desc <<-LONGDESC
        Removes (deletes) a puter image.

        With --templates option, looks for image in the given vSphere folder.
      LONGDESC
      option :templates, :type => :string, :default => '/Templates', :banner => '/path/to/puter/templates'
      def rmi(name, templates_path = options[:templates])
        CLI.run_cli do
          vm.rmi "#{templates_path}/#{name}"
        end
      end

      desc "rm NAME", "Removes (deletes) a puter instance."
      long_desc <<-LONGDESC
        Removes (deletes) a puter instance.

        NAME must be the full vSphere folder path and VM name.
      LONGDESC
      def rm(name)
        CLI.run_cli do
          vm.rm name
        end
      end

      private

      def vm
        @vm ||= Puter::Provider::Vm.new
      end
    end
  end
end
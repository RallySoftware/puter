require 'puter/providers/vm'
require 'puter/backend/ssh'

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

      desc "apply NAME CONTEXT", "Applies Puterfile to an existing & running VM."
      long_desc <<-LONGDESC
        Applies Puterfile to an existing & running VM.
      LONGDESC
      def apply(vm_name, context)
        CLI.run_cli do
          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          vm.host(vm_name) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{vm_name}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
          end
          Puter.ui.info "Successfully applied '#{puterfile_path}' to '#{vm_name}'"
        end
      end

      desc "build NAME CONTEXT", "Creates a new puter image."
      long_desc <<-LONGDESC
        Builds a new puter image.

        With --templates option, looks for the Puterfile FROM image in the given vSphere folder.
      LONGDESC
      option :templates, :type => :string,  :default => '/Templates', :banner => "/path/to/puter/templates"
      option :force, :type => :boolean,  :default => false, :banner => "overwrites NAME if it exists"
      def build(vm_name, context, opts = options)
        CLI.run_cli do
          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          Puter.ui.info "FROM '#{opts[:templates]}/#{puterfile.from}'"
          Puter.ui.info "Waiting for SSH"
          vm.build(vm_name, "#{opts[:templates]}/#{puterfile.from}", opts) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{vm_name}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
            Puter.ui.info "Stopping '#{vm_name}'"
          end
          Puter.ui.info "Successfully built '#{vm_name}'"
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
          ## TODO do some UI output
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
          ## TODO do some UI output
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
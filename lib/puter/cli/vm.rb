require 'puter/providers/vm'
require 'puter/backend/ssh'

module Puter
  module CLI
    class Vm < Thor
      desc 'images', 'Lists available puter images.'
      long_desc <<-LONGDESC
        Lists available puter images.

        With --images option, lists images found in the given vSphere folder.
      LONGDESC
      option :images, :type => :string, :default => '/Puter/Images', :banner => '/path/to/Puter/Images'
      def images()
        CLI.run_cli do
          vm.images(options[:images]).each { |i| Puter.ui.info i }
        end
      end

      desc "apply NAME CONTEXT", "Applies Puterfile to an existing & running VM."
      long_desc <<-LONGDESC
        Applies Puterfile to an existing & running VM.

        With --instances option, operates on instances in the given vSphere folder.
      LONGDESC
      option :instances, :type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances'
      def apply(vm_name, context)
        CLI.run_cli do
          vm_path = "#{options[:instances]}/#{vm_name}"
          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          vm.host(vm_path) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{vm_path}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
          end
          Puter.ui.info "Successfully applied '#{puterfile_path}' to '#{vm_name}'"
        end
      end

      desc "build NAME CONTEXT", "Creates a new puter image."
      long_desc <<-LONGDESC
        Builds a new puter image.

        With --images option, looks for the Puterfile FROM image in the given vSphere folder.
        With --build option, uses the given vSphere folder as a working folder.
      LONGDESC
      option :images, :type => :string, :default => '/Puter/Images', :banner => '/path/to/Puter/Images'
      option :build,  :type => :string, :default => '/Puter/Build',  :banner => '/path/to/Puter/Build'
      option :force,  :type => :boolean,  :default => false, :banner => "overwrites NAME if it exists"
      def build(image_name, context, opts = options)
        CLI.run_cli do
          build_path = "#{options[:build]}/#{image_name}"
          image_path = "#{options[:images]}/#{image_name}"

          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          Puter.ui.info "Building '#{images_path}' FROM '#{opts[:images]}/#{puterfile.from}'"
          Puter.ui.info "Waiting for SSH"
          vm.build(build_path, image_path, "#{opts[:images]}/#{puterfile.from}", opts) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{build_path}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
            Puter.ui.info "Stopping '#{build_path}' and moving to '#{image_path}'"
          end
          Puter.ui.info "Successfully built '#{image_name}'"
        end
      end

      desc "rmi NAME", "Removes (deletes) a puter image."
      long_desc <<-LONGDESC
        Removes (deletes) a puter image.

        With --images option, looks for image in the given vSphere folder.
      LONGDESC
      option :images, :type => :string, :default => '/Puter/Images', :banner => '/path/to/puter/images'
      def rmi(name, images_path = options[:images])
        CLI.run_cli do
          vm.rmi "#{images_path}/#{name}"
          Puter.ui.info "Removed image '#{name}'"
        end
      end

      desc "create IMAGE NAME", "Creates (clones) a puter instance from IMAGE as NAME."
      long_desc <<-LONGDESC
        Creates (clones) a puter instance from IMAGE as NAME.

        With --images option, looks for the Puterfile FROM image in the given vSphere folder.
        With --instances option, operates on instances in the given vSphere folder.
      LONGDESC
      option :images, :type => :string, :default => '/Puter/Images', :banner => '/path/to/Puter/Images'
      option :instances, :type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances'
      def create(image_name, instance_name)
        CLI.run_cli do
          image_path = "#{options[:images]}/#{image_name}"
          instance_path = "#{options[:instances]}/#{instance_name}"

          vm.create image_path, instance_path
          Puter.ui.info "Created instance '#{instance_path}' from '#{image_path}'"
        end
      end

      desc "ps", "Lists Puter instances"
      long_desc <<-LONGDESC
        Lists Puter instances.

        With --all option, lists stopped instances.
        With --instances option, operates on instances in the given vSphere folder.
      LONGDESC
      option :instances, :type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances'
      option :all, :type => :boolean, :default => false
      def ps()
        CLI.run_cli do
          vm.ps(options[:instances], options[:all]).each { |i| Puter.ui.info i }
        end
      end

      desc "start NAME", "Runs a Puter instance."
      long_desc <<-LONGDESC
        Runs a Puter instance.

        With --instances option, operates on instances in the given vSphere folder.
      LONGDESC
      option :instances, :type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances'
      def start(instance_name)
        CLI.run_cli do
          instance_path = "#{options[:instances]}/#{instance_name}"

          Puter.ui.info "Starting instance '#{instance_path}', waiting for SSH..."
          vm.start instance_path do |host|
            Puter.ui.info "Started '#{instance_path}' at #{host}."
          end
        end
      end

      desc "rm NAME", "Removes (deletes) a puter instance."
      long_desc <<-LONGDESC
        Removes (deletes) a puter instance.

        With --instances option, operates on instances in the given vSphere folder.
      LONGDESC
      option :instances, :type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances'
      def rm(name)
        CLI.run_cli do
          vm.rm name
          Puter.ui.info "Removed instance '#{name}'"
        end
      end

      desc "init PATH", "Initializes Puter VM folders in VMware"
      long_desc <<-LONGDESC
        Initializes Puter VM folders in VMware.

        Creates the following folder hierarchy:

        PATH/        - default: /Puter
          Build/     - working folder for building Puter images
          Images/    - Puter images (VM Templates)
          Instances/ - Putere instances (VMs)

        PATH must be the full vSphere folder path name, e.g. '/Puter'.
      LONGDESC
      def init(path = '/Puter')
        CLI.run_cli do
          vm.init(path)
          Puter.ui.info "Create Puter folders under #{path}"
        end
      end

      private

      def vm
        @vm ||= Puter::Provider::Vm.new
      end
    end
  end
end
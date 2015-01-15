require 'puter/providers/vm'
require 'puter/backend/ssh'

module Puter
  module CLI
    class Vm < Thor
      images_option =    [:images,    {:type => :string, :default => '/Puter/Images',    :banner => '/path/to/Puter/Images',    :desc => 'Override the default Images vSphere folder.'    }]
      instances_option = [:instances, {:type => :string, :default => '/Puter/Instances', :banner => '/path/to/Puter/Instances', :desc => 'Override the default Instances vSphere folder.' }]
      build_option =     [:build,     {:type => :string, :default => '/Puter/Build',     :banner => '/path/to/Puter/Build',     :desc => 'Override the default Build vSphere folder.'     }]

      desc 'images', 'Lists available Puter images.'
      method_option *images_option
      def images()
        CLI.run_cli do
          vm.images(options[:images]).each { |i| Puter.ui.info i }
        end
      end

      desc "apply NAME CONTEXT", "Applies Puterfile to an existing & running VM"
      method_option *instances_option
      def apply(instance_name, context)
        CLI.run_cli do
          instance_path = "#{options[:instances]}/#{instance_name}"
          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          vm.host(instance_path) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{instance_path}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
          end
          Puter.ui.info "Successfully applied '#{puterfile_path}' to '#{instance_name}'"
        end
      end

      desc "build NAME CONTEXT", "Builds a new Puter image"
      method_option *images_option
      method_option *build_option
      option :force,  :type => :boolean,  :default => false, :description => "Replaces Image specified by NAME if it exists"
      def build(image_name, context)
        CLI.run_cli do
          build_path = "#{options[:build]}/#{image_name}"
          images_path = "#{options[:images]}/#{image_name}"

          puterfile_path = File.expand_path 'Puterfile', context
          puterfile = Puter::Puterfile.from_path puterfile_path

          Puter.ui.info "Building '#{images_path}' FROM '#{options[:images]}/#{puterfile.from}'"
          Puter.ui.info "Waiting for SSH"
          vm.build(build_path, images_path, "#{options[:images]}/#{puterfile.from}", options) do |host|
            Puter.ui.info "Applying '#{puterfile_path}' to '#{build_path}' at #{host}"
            backend = Puter::Backend::Ssh.new(host, Puter::CLI::SSH_OPTS)
            ret = puterfile.apply(context, backend, Puter.ui)
            Puter.ui.info "Stopping '#{build_path}' and moving to '#{images_path}'"
          end
          Puter.ui.info "Successfully built '#{image_name}'"
        end
      end

      desc "rmi NAME", "Removes (deletes) a Puter image"
      method_option *images_option
      def rmi(image_name)
        image_path = "#{options[:images]}/#{image_name}"
        CLI.run_cli do
          vm.rmi image_path
          Puter.ui.info "Removed image '#{image_path}'"
        end
      end

      desc "create IMAGE NAME", "Creates (clones) a Puter instance from IMAGE as NAME"
      method_option *images_option
      method_option *instances_option
      option :force,  :type => :boolean,  :default => false, :description => "Replaces Instance specified by NAME if it exists"
      def create(image_name, instance_name)
        CLI.run_cli do
          image_path = "#{options[:images]}/#{image_name}"
          instance_path = "#{options[:instances]}/#{instance_name}"

          vm.create image_path, instance_path, options
          Puter.ui.info "Created instance '#{instance_path}' from '#{image_path}'"
        end
      end

      desc "ps", "Lists Puter instances"
      method_option *instances_option
      option :all, :type => :boolean, :default => false, :description => 'Includes non-running instances.'
      def ps()
        CLI.run_cli do
          vm.ps(options[:instances], options[:all]).each { |i| Puter.ui.info i }
        end
      end

      desc "start NAME", "Starts a Puter instance"
      method_option *instances_option
      def start(instance_name)
        CLI.run_cli do
          instance_path = "#{options[:instances]}/#{instance_name}"

          Puter.ui.info "Starting instance '#{instance_path}', waiting for SSH..."
          vm.start instance_path do |host|
            Puter.ui.info "Started '#{instance_path}' at #{host}."
          end
        end
      end

      desc "rm NAME", "Removes (deletes) a Puter instance"
      method_option *instances_option
      def rm(instance_name)
        CLI.run_cli do
          instance_path = "#{options[:instances]}/#{instance_name}"
          vm.rm instance_path
          Puter.ui.info "Removed instance '#{instance_path}'"
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
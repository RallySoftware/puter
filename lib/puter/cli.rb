require 'puter/version'
require 'puter/cli/vm'
require 'puter/cli/aws'

module Puter
  module CLI
    EXIT_CODE_ERR = 1

    SSH_OPTS = {}
    SSH_OPTS[:user]                  =  ENV['SSH_USER'] || 'root'
    SSH_OPTS[:password]              =  ENV['SSH_PASSWORD']         if ENV['SSH_PASSWORD']
    SSH_OPTS[:port]                  =  ENV['SSH_PORT'].to_i        if ENV['SSH_PORT']
    SSH_OPTS[:paranoid]              = (ENV['SSH_PARANOID'] == '1') if ENV['SSH_PARANOID']
    SSH_OPTS[:user_known_hosts_file] =  ENV['SSH_KNOWN_HOSTS']      if ENV['SSH_KNOWN_HOSTS']

    def self.run_cli(&block)
      begin
        block.call
      rescue Puter::RunError => re
        Puter.ui.error re.message
        Puter.ui.error "[ #{re.cmd} ] returned [ #{re.exit_status} ]"
        Puter.ui.error re.backtrace.join "\n"
        exit re.exit_status
      rescue Exception => e
        Puter.ui.error e.message
        Puter.ui.error e.backtrace.join "\n"
        exit EXIT_CODE_ERR
      end
      exit 0
    end

    class Cli < Thor
      def self.exit_on_failure?
        true
      end

      ALIASES = {
        '-T'         => 'help',
        '--version'  => 'version',
        '-V'         => 'version'
      }

      map ALIASES

      desc 'vm', "VMware vSphere related tasks. Type #{Puter.executable_name} vm for more help."
      subcommand 'vm', Vm

      desc 'aws', "Amazon AWS related tasks. Type #{Puter.executable_name} aws for more help. NOT IMPLEMENTED."
      subcommand 'aws', Aws

      class_option :version, :type => :boolean, :desc => 'Show program version'
      desc 'version', 'Display puter version.'
      def version
        Puter.ui.info "#{Puter.executable_name} #{Puter::VERSION}"
      end
    end
  end
end

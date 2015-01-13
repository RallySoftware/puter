require 'net/ssh'
require 'net/scp'

module Puter
  module Backend
    class SshError < Exception
    end

    # TODO - pass in a logger, so that stdout and stderr can stream out directly?

    class Ssh
      def initialize(host, ssh_opts = {})
        @ssh = Net::SSH.start( host, ssh_opts[:user] || 'root', ssh_opts )
        @scp = Net::SCP.new(@ssh)
      end

      def run(command, user='root', opts={}, &output)
        actual_cmd = "sudo -u #{user} -s -- sh -c '#{command}'"
        stdout_data = ''
        stderr_data = ''
        exit_status = nil
        exit_signal = nil

        @ssh.open_channel do |channel|
          # TODO - make request_pty user controllable:
          #          without a pty, RHEL default configs fail to allow sudo
          #          with a pty, openssh comingles stdout and stderr onto stdout
          channel.request_pty do |ch, success|
            raise SshError.new "Could not obtain SSH pty " if !success
          end

          channel.exec(actual_cmd) do |ch, success|
            raise SshError.new "Could not execute command [ #{actual_cmd} ]" if !success
            channel.on_data do |ch, data|
              if output
                output.call(:stdout, data) if output
              else
                stdout_data += data
              end
            end

            channel.on_extended_data do |ch, type, data|
              if output
                output.call(:stderr, data) if output
              else
                stderr_data += data
              end
            end

            channel.on_request("exit-status") do |ch, data|
              exit_status = data.read_long
            end

            channel.on_request("exit-signal") do |ch, data|
              exit_signal = data.read_long
            end
          end
        end
        @ssh.loop
        { :cmd => actual_cmd, :stdout => stdout_data, :stderr => stderr_data, :exit_status => exit_status, :exit_signal => exit_signal }
      end

      def add(from, to)
        @scp.upload! from, to
      end

    end
  end
end
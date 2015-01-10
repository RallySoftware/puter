module Puter
  module CLI
    class Aws < Thor
      desc 'images', 'Lists available puter images.'
      long_desc <<-LONGDESC
        Lists available puter images.

        With --region option, lists images found in the given AWS region.
      LONGDESC
      option :region, :type => :string, :default => 'us-west-1', :banner => 'aws-region-name'
      def images(region_name = options[:region])
        CLI.run_cli do
          raise 'NOT IMPLEMENTED'
        end
      end
    end
  end
end
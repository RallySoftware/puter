require 'vmonkey'
require 'puter/puterfile'

module Puter
  module Provider
    class Vm

      def images(path, sub="")
        folder = vmonkey.folder!(path)
        imgs = folder.templates.collect { |t| "#{sub}#{t.name}" }
        folder.folders.each do |sub_folder|
          imgs += images("#{path}/#{sub_folder.name}", "#{sub}#{sub_folder.name}/")
        end
        imgs
      end

      def host(name, &block)
        target = vmonkey.vm! name
        block.call(target.guest_ip)
      end

      def build(build_name, image_name, template_name, opts, &block)
        template = vmonkey.vm! template_name
        if opts[:force]
          build = template.clone_to! build_name
        else
          build = template.clone_to build_name
        end

        build.start
        build.wait_for_port 22
        block.call(build.guest_ip) if block
        build.stop
        build.MarkAsTemplate()

        if opts[:force]
          build.move_to! image_name
        else
          build.move_to image_name
        end
      end

      def rmi(path)
        vmonkey.template!(path).destroy
      end

      def create(image_name, instance_name, opts)
        if opts[:force]
          vmonkey.vm!(image_name).clone_to! instance_name
        else
          vmonkey.vm!(image_name).clone_to instance_name
        end
      end

      def start(instance_name, &block)
        instance = vmonkey.vm!(instance_name)
        instance.start
        instance.wait_for_port 22
        block.call(instance.guest_ip) if block
      end

      def ps(instances_path, all, sub="")
        folder = vmonkey.folder! instances_path
        instances = folder.vms
        instances.select! { |vm| vm.runtime.powerState == 'poweredOn' } unless all
        # instances.collect(&:name)

        ret = instances.collect { |i| "#{sub}#{i.name}" }
        folder.folders.each do |sub_folder|
          ret += ps("#{instances_path}/#{sub_folder.name}", all, "#{sub}#{sub_folder.name}/")
        end
        ret
      end

      def rm(path)
        vmonkey.vm!(path).destroy
      end

      def init(path)
        root = vmonkey.folder '/'
        root.mk_folder "#{path}/Build"
        root.mk_folder "#{path}/Images"
        root.mk_folder "#{path}/Instances"
      end

      def vmonkey
        @vmonkey ||= VMonkey.connect
      end

    end
  end
end

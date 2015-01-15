VMware Puter structure within a Datacenter
  Puter/
    Build/
      # 'puter vm build' - uses this directory as a working folder

    Images/
      # in all commands, NAME is relative to here
      # 'puter vm images' - lists recursively
      # 'puter vm build NAME' - builds a new VM image
      #    Puterfile FROM is also relative to here e.g. FROM rallydev.com/os/centos5
      # 'puter vm rmi NAME' - destroys a VM image

      rallydev.com/
        os/
          coreos
          centos5
          centos6
        platform/
          docker_on_centos
          java8_app_server

    Instances/
      # in all commands, NAME is relative to here
      # 'puter vm ps' - lists recursively (-a for stopped VMs, too)
      # 'puter vm create IMAGE NAME' - IMAGE is relative to above
      # 'puter vm start NAME' - starts a VM
      # 'puter vm stop NAME' - stops a VM
      # 'puter vm rm NAME' - destroys a vm

      realtime/
        bld-pigeon-01
        bld-alm-01

AWS Puter Structure, within an EC2 Region

## What's been implemented

VMware provider, using the vmonkey and rbvmomi APIs.
Puterfile instructions: FROM, RUN, and COPY
puter vm sub-commands: images, build, rmi, ps, create, start, stop, rm, apply

## What needs to be implemented

### Enhance puter sub-commands

    `ps`     - detailed output, currently only names are output.
    `images` - detailed output, currently only names are output.

### Implement puter sub-commands

    `version` -
    `run`     - convenience for create & start
    `restart` - guest OS restart
    `exec`    - run a command on the guest OS
    `inspect` - detailed metadata of an image/instance
    `implode` - completely remove all Puter images, instances, and provider-specific metadata

    `tag`     - maybe?
    `import`  - maybe?  dups an existing non-Puter image (template, ami) into the set of Puter Images
    `export`  - maybe?  dups an existing Puter Image to a non-Puter image (template, ami)


### Implement Puterfile instructions

    `MAINTAINER`
    `USER`
    `ENV`
    `VOLUME`
    `ADD`
    `EXPOSE`
    `ONBUILD`

### Implement an AWS provider


## VMware provider

### VMware Puter structure within a Datacenter

    <datacenter>/     # VMonkey config specifies the specific Datacenter to operate from
      vmFolder/       #
        Puter/        # top-level vSphere Folder - 'puter vm init' creates this folder
          Build/      # this folder is used by 'puter vm build' as a working folder
          Images/     # this folder is where Puter Images (VM templates) are stored
          Instances/  # this folder is where Puter Images (running and stopped VMs) are stored

## AWS Puter Structure, within an EC2 Region

    tbd

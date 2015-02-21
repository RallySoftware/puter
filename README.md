# Puter: provision VMs in a Docker-like way

Puter is a tool to quickly and easily provision virtual machine images and
instances directly on virtualization and cloud providers.

Using a Puterfile syntax that closely resembles Dockerfile syntax, Puter makes
it easy and familiar to create new base VM images.

## Usage Example
Given a repo with the following structure:

    example/
    |-- Puterfile
    |-- localfile.txt
    |-- localfile_with_a_really_really_longname.txt

### Puterfile
    FROM myorg.tld/baseos
    # Start with any base image on your virtualization provider

    # Run some simple commands
    RUN touch /tmp/puter.txt
    RUN userdel -f puter1; useradd puter1
    RUN sudo -u puter1 whoami

    # Copy some files to the new machine
    COPY localfile.txt /tmp/explicit_name.txt

    # Extend long lines with \ syntax
    COPY localfile_with_a_really_really_longname.txt \
         /home/puter1/

    # Don't fear shell redirection and special characters
    RUN touch /tmp/puter.txt && \
        echo more commands > /tmp/puter.txt && \
        echo done
    RUN echo puter1 >> /tmp/puter.txt

    # output from long running commands is visible along the way
    RUN for i in `seq 1 5`; do echo $i; sleep 1; done;

    RUN echo complete


### Build an image
    $ puter vm build myorg.tld/puterWithStuff examples
    Building '/Puter/Images/myorg.tld/puterWithStuff' FROM '/Puter/Images/c65.small'
    Waiting for SSH
    Applying '/Users/pairing/projects/puter/examples/Puterfile' to '/Puter/Build/myorg.tld/puterWithStuff' at 10.0.0.123
    Step 0 : FROM myorg.tld/baseos
    Step 1 : RUN touch /tmp/puter.txt
    Step 2 : RUN userdel -f puter1; useradd puter1
    userdel: user 'puter1' does not exist
    Step 3 : RUN sudo -u puter1 whoami
    puter1
    Step 4 : COPY localfile.txt /tmp/explicit_name.txt
    Step 5 : COPY localfile_with_a_really_really_longname.txt  /home/puter1/
    Step 6 : RUN touch /tmp/puter.txt &&  echo more commands > /tmp/puter.txt &&  echo done
    done
    Step 7 : RUN echo puter1 >> /tmp/puter.txt
    Step 8 : RUN for i in `seq 1 5`; do echo $i; sleep 1; done;
    1
    2
    3
    4
    5
    Step 9 : RUN echo complete
    complete
    Stopping '/Puter/Build/myorg.tld/puterWithStuff' and moving to '/Puter/Images/myorg.tld/puterWithStuff'
    Successfully built 'myorg.tld/puterWithStuff'

    ### Build an image


### Create and start an instance
    $ puter vm create myorg.tld/puterWithStuff puter1
    Created instance '/Puter/Instances/puter1' from '/Puter/Images/myorg.tld/puterWithStuff'

    $ puter vm start puter1
    Starting instance '/Puter/Instances/puter1', waiting for SSH...
    Started '/Puter/Instances/puter1' at 10.32.30.126.


### Virtualization providers
Currently only VMware vSphere is supported.
Amazon AWS support is planned.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install puter

## Usage

    $ puter help
    Commands:
    puter help [COMMAND]  # Describe available commands or one specific command
    puter version         # Display puter version.
    puter vm              # VMware vSphere related tasks. Type puter vm for more help.

    Options:
    [--version], [--no-version]  # Show program version


## Contributing

1. Fork it ( https://github.com/[my-github-username]/puter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

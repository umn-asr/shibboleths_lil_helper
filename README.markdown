About
=====
WARNING: THIS IS VERY BETA RIGHT NOW
WARNING: THIS IS VERY BETA RIGHT NOW
WARNING: THIS IS VERY BETA RIGHT NOW
WARNING: THIS IS VERY BETA RIGHT NOW

A Rubygem to help manage the configuration associated with many instances of the Shibboleth Apache/IIS Native Service Provider code.

Background
==========
It was created to help ease the pain of a large shibboleth migration project for 
* ~6 web servers (both IIS6 & Apache 2.2)
* >~6 vhosts
* running PHP, Rails 2 + 3, classic ASP, .NET 
* at the University of Minnesota, Academic Support Resources.

We needed an approach that could handle all of these languages and servers
so went with the [[Apache/IIS Native Service Provider]] approach.

Since the Native SP approach pushes critical app auth logic to the web
server layer of the stack, we need a way to keep this logic versioned with the application itself.

Installation
============
TODO
Apache Assumptions
===========
* Shibboleth Native Service Provider is already installed on your target server.
* the Shibboleth apache module is loaded globally for all vHosts
  This is typically done for you, but if not: something like this might work:
  cp /etc/shibboleth/apache22.conf /etc/httpd/conf/shib.conf

Usage
=====
* type "slh initialize"
  > The first time this happens it will create a
  > "shibboleths_lil_helper" dir and an example config.rb you should
  > customize to meet your deployment needs
* customize the shibboleths_lil_helper/config.rb
* type "slh generate"
  > It will generate a directory structure like the following
  shibboleths_lil_helper/
    generated/
      <strategy>/
        <host>/
          shibboleth2.xml
          attribute-map.xml
          idp_metadata.xml
          <site>/
            shib_for_vhost.conf
  > Where <strategy>, <host>, and <app> are the dynamic names of your
  > stuff, extracted from the config.rb file.

* Check this code into source control.  This defines the shib auth rules
  across your entire organization.
* copy the generated shibboleth config files to the remote server, and
  restart shibd
* 

Usage within Apps
=====================
If you are using git, submodule the shibboleths_lil_helper directory
into your project.  This will serve as a reference to how the server is
configured.

Usage with Capistrano (or other deployment automation tool)
===========================================================
TODO: HANDLE THIS ONCE THE FIRST STUFF IS DONE...
The generated config files from the 'slh generate' command is
consistent, so with Capistrano, you set the after_symlink hook to "slh
generate", then copy shibboleth2.xml, attribute-map, and other apache
files to where they need to go on the server....







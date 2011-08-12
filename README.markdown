About
=====
WARNING: THIS IS VERY BETA RIGHT NOW
A Rubygem to help manage the configuration associated with many instances of the Shibboleth Apache/IIS Native Service Provider code.

Inspiration: Thank you Santa Clause
===================================

While Santa should be respected for his hard word, jolly attitude, and
dedication to dole out toys to weasels planet-wide, his elves deserve some
props as well!...There are lots of little things that need to be done.

  Santa provides the toys, elves do the dirty work.
  Shibboleth provides the auth, it's lil helpers do the dirty work.

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
gem install shibboleths_lil_helper

Assumptions
===========
TODO: (lots of them...shoots to solve the dominant use case/simple path: 1 IDP)

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
          <app>/
            shib_apache.conf
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







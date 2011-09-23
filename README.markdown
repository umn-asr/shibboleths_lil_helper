About
=====
A Rubygem to help manage the configuration associated with many instances of the Shibboleth Apache/IIS Native Service Provider code.
(WARNING: This is in active development and is fairly unstable, unless
you've talked to Joe or Chris regarding this tool, beware).

Background
==========
It was created to manage shibboleth configuration and deployment across
* iis6, iis7, and Apache 2.2 web servers
*   each hosting many vhosts (aka sites)
*   each running PHP, Rails 2 + 3, classic ASP, and .NET
*   running the Apache/IIS Native Service Provider

Installation
============
1. gem install shibboleths_lil_helper (DEV_WISH_LIST: Not working yet)
2. git clone git://github.com/joegoggins/shibboleths_lil_helper.git

Assumptions
===========
* Shibboleth Native Service Provider Apache/IIS is already installed on your target web servers.
* The Shibboleth apache module is loaded globally for all vHosts
* /bin/slh is in your $PATH (automatically done with Rubygem install
  method, manual is git cloned

Usage
=====
* Type `slh`, you will see instructions for each sub-command and how
  to get additional information about them.  In general the process is
  * [initialize] initialize a shibboleths_lil_helper/config.rb
  * [in your editor] tweak shibboleths_lil_helper/config.rb to reflect the servers you
    will be using shibboleth with
  * [generate] generate shibboleth2.xml, attribute-map.xml, and other Native Sib
    config files
  * [a deployment tool or manually] deploy these files out to each host using Capistrano (DEV_WISH_LIST,TODO: Though the initialize command does drop a config/deploy.rb there is no documenation of its usage or examples of how it should be used)
  * [metadata] generate metadata

Concept
=======
Most of the `slh` sub-commands are simply config file generators that place
generated content into a directory structure in the current working like
like follows:

    shibboleths_lil_helper/
      generated/
        <strategy>/               (apache_shib_test_server)
          <institution>/          (umn.edu)
            <templating_flavor/   (oit-vms)
              <hostname>/         (asr-web-dev4.oit.umn.edu)
                attribute-map.xml
                idp_metadata.xml
                shib_apache.conf
                shibboleth2.xml
                sp_metadata_for_host_to_give_to_idp.xml 
                <site>/           (shib-php-test.asr.umn.edu)
                  fetched_metadata.xml


* You should check these generated files into source control. 

Real World Example
==================
We have a private repo called shibboleth_deployer that includes the shibboleths_lil_helper generated config files and uses Capistrano to push these files out target servers and restarts shibd.  It's usage looks like:
    cap deploy HOST=asr-web-dev4.oit.umn.edu

For each of our target servers we setup Capistrano to have a clone of
this shibboleth_deployer repo structured in the standard way, e.g:

    ls /etc/shibboleth_deployer
        current
        releases
        shared

Setup symlinks to the appropriate config files within
shibboleth_deployer from the places the Native Shibboleth SP expects
files to be, e.g:

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/umn.edu/oit-vms/asr-web-dev4.oit.umn.edu/shibboleth2.xml /etc/shibboleth/shibboleth2.xml

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/umn.edu/oit-vms/asr-web-dev4.oit.umn.edu/idp_metadata.xml /etc/shibboleth/idp_metadata.xml

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/umn.edu/oit-vms/asr-web-dev4.oit.umn.edu/attribute-map.xml /etc/shibboleth/attribute-map.xml

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/umn.edu/oit-vms/asr-web-dev4.oit.umn.edu/shib_apache.conf /etc/httpd/conf.d/shib_apache.conf


How to Help
======================

Email Us
----------------------
* Let us know you are using the tool.  Tell us what things you had
  difficulties with.

* Voice you ideas about features you'd like to see.

Contribute to the code
----------------------
* Grep for DEV_WISH_LIST, DEPRECATE, or TODO these are areas in the code or docs that need
  work.

* We'll shortly post additional information about how developers can
  contribute. DEV_WISH_LIST: TODO:JOE.

Authors
=======
* Joe Goggins, Academic Support Resources, goggins@umn.edu
* Chris Dinger, Academic Support Resources, ding0057@umn.edu


Copyright (c) 2011 University of Minnesota

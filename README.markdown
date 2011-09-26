About
=====
Shibboleth's Lil Helper is a tool that automates the generation of Apache/IIS Shibboleth Native Service Provider configuration & metadata files.  It provides several benefits over manually configuring each NativeSp instance/server by:

* __Providing a consistent configuration approach__ you can apply uniformly across all of the servers managed by your organization.
  * Makes deployment automation possible, errors less frequent, and troubleshooting easier.

* __Dividing high level auth specs from actual NativeSp configuration__
  * Programmers can focus on high level goals like "protect files underneath the '/secure' directory on 'somewebsite.com'" rather than grappeling with the bewildering complexity of the NativeSp's interrelated XML files, the Shibboleth protocal, SAML, etc.  

* __Providing conceptually simple linear process__ that distills the main steps associated with Shibboleth integration.

**WARNING**: This is in active development and is unstable. 
Unless you've talked to Joe or Chris regarding this tool, beware.

Why another tool?
-----------------
We needed something that could help manage shibboleth configuration and deployment across our various web servers:

* iis6, iis7, and Apache 2.2
  * each hosting many vhosts (aka sites)
  * each running PHP, Rails 2 + 3, classic ASP, and .NET
  * each running the Apache/IIS Native Service Provider

Installation
============
* Pre-requisites:
  * Rubygems: http://rubygems.org/pages/download
  * Bundler: gem install bundler
  
* From github:
    git clone git://github.com/joegoggins/shibboleths_lil_helper.git
    cd shibboleths_lil_helper
    bundle
    ./bin/slh
    (follow instructions)

* Via Ruby Gems: Not working yet

Assumptions
===========
* Shibboleth Native Service Provider Apache/IIS is already installed on your target web servers.
* The Shibboleth apache module is loaded globally for all vHosts
* /bin/slh is in your $PATH (automatically done with Rubygem install
  method, manual is git cloned

Concept
=======

Auth specs are stated in your shibboleths_lil_helper/config.rb
via an easily readable ruby parseable domain specific language.  From these specs, Shibboleth's Lil Helper is capable of generating all of the required XML files you will need to integrate with
a Shibboleth Identify Provider (Idp).

The generation of these XML files happens through a command line tool
called "slh".  Each particular task is broken into sub-commands such as
"initialize", "generate", or "metadata" that perform various tasks.

For example, given the following shibboleths_lil_helper/config.rb:

    Slh.for_strategy :umn_apache_shib_test_server do
      set :sp_entity_id, 'https://asr.umn.edu/shibboleth/default'
      set :idp_metadata_url, 'https://idp-test.shib.umn.edu/metadata.xml'
      set :error_support_contact, 'goggins@umn.edu'
      set :template_dir, 'umn.edu/oit-vms'
      for_host 'asr-web-dev4.oit.umn.edu' do
        set :shib_prefix, "/swadm/etc/shibboleth"
        for_site 'shib-php-test.asr.umn.edu' do
          protect 'secure'
        end
        for_site 'shib-rails2-test.asr.umn.edu' do
          protect 'secure'
        end
      end
    end

an invocations of

    `slh generate`

will produce the a dir structure and various config files
associated with these specifications for each strategy, host, and site.

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

* These generated files should be checked into a source control repository.

The core assumptions of the specifications DSL are

* a strategy ("for_strategy")
  * has one IDP entity id (:idp_metadata_url)
  * has one service provider entity id (:sp_entity_id)
  * has one template_dir used to translate specs into config XML (:template_dir)
  * has many hosts
* a host (for_host)
  * has many sites 
* a site (for_site)
  * has many site paths that have various auth rules
* a site path (protect)
  * has a "flavor" such as the following specified like
    *protect "optional_auth", :flavor => :authentication_optional*
    * authentication_required
    * authentication_optional
    * authentication_required_for_specific_users


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

Real World Example
==================
The following describes how we integrate this tool's generated output
into a deployment automation tool called Capistrano.

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

About
=====
Shibboleth's Lil Helper is a tool that automates the generation of Apache/IIS Shibboleth Native Service Provider configuration & metadata files.  It provides several benefits over manually configuring each NativeSp instance/server by:

* __Providing a consistent configuration approach__ you can apply uniformly across all of the servers managed by your organization.
  * Makes deployment automation possible, errors less frequent, and troubleshooting easier.

* __Dividing high level auth specs from actual NativeSp configuration__
  * Programmers can focus on high level goals like "protect files underneath the '/secure' directory on 'somewebsite.com'" rather than grappeling with the bewildering complexity of the NativeSp's interrelated XML files, the Shibboleth protocal, SAML, etc.  

* __Providing conceptually simple linear process__ that distills the main steps associated with Shibboleth integration.

IMPORTANT NOTE/DISCLAIMER
-------------------------
All you see here on Github is the readme, no code yet.
For that to happen two things need to occur:

* We need to battle-test the (working) code across our entire
  infrastructure and fix bugs before releasing.

* Someone from the IDM team within OIT needs approve that our approach
  is solid and endorse its usage for the U of M.

**The current status as of October 6th, 2011**

* We have it working in PHP, .NET, and Rails on 2 servers and 4 vhosts for Apache and IIS.

* Assuming no snags (cause that never happens in software, :)), we
anticipate 90% of our infrastructure migrated by Nov 1st.  At which
point we hope to release this code into the wild.  And perhaps do a demo
session at a Code-People meeting.

Why another tool?
-----------------
We needed something that could help manage shibboleth SP
configuration consistently with minimal manual work for:

* Many web servers
  * each running iis6, iis7, or Apache 2.2
  * each hosting many vhosts (aka sites)
  * each running PHP, Rails 2 + 3, classic ASP, or .NET
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
      (then follow instructions)

* Via Ruby Gems: Not working yet

Assumptions
===========
* Shibboleth Native Service Provider Apache/IIS is already installed on your target web servers.
* The X509Certificate (sp-cert.pem, sp-key.pem) keys are in their default locations along-side shibboleth2.xml.  This tool does not help you generate these keys, that's up to you.  The default installation of Native Shib generates keys for you though.
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
      for_host 'asr-web-dev4.oit.umn.edu' do
        for_site 'shib-php-test.asr.umn.edu' do
          protect 'secure'
        end
        for_site 'shib-rails2-test.asr.umn.edu' do
          protect 'secure'
        end
      end
    end

an invocation of

    `slh generate`

will produce the a dir structure and various config files
associated with these specifications for each strategy, host, and site.

    shibboleths_lil_helper/
      generated/
        <strategy>/               (apache_shib_test_server)
          <hostname>/             (asr-web-dev4.oit.umn.edu)
            idp_metadata.xml
            shib_apache.conf
            shibboleth2.xml
            sp_metadata_for_host_to_give_to_idp.xml 
            <site>/               (shib-php-test.asr.umn.edu)
              fetched_metadata.xml


* The generated shibboleth2.xml will have RequestMap specs that restrict
  access to the "/secure" path for the specified vhosts.

* These generated files should be checked into a source control repository.

The core assumptions of the specifications DSL are

* a strategy ("for_strategy")
  * has one IDP entity id (:idp_metadata_url)
  * has one service provider entity id (:sp_entity_id)
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
  * [generate] generate shibboleth2.xml, shib_apach.conf
    config files
  * [a deployment tool or manually] deploy these files out to each host (ideally using a deployment automation tool such as Capistrano)
  * [metadata] generate metadata: creates and combines SP Metadata from all
    of the Shib servers into a file(s) you can share with your IDP.
  * [email] send the generated meta data to your IDP

Real World Example
==================
The following describes how we integrate this tool's generated output
into a deployment automation tool called Capistrano.

We have a private repo called shibboleth_deployer that includes the shibboleths_lil_helper generated config files and uses Capistrano to push these files out target servers and restarts shibd and httpd.  It's usage looks like:

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

(from the /etc/shibboleth dir)
    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/shibboleth2.xml shibboleth2.xml

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/idp_metadata.xml idp_metadata.xml

(from the /etc/httpd/conf.d dir)
    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/shib_apache.conf shib_apache.conf

How to Help
======================

Email Us
----------------------
* Let us know you are interested in using the tool.

* Voice you ideas about questions you have and features you'd like to see.

Authors
=======
* Joe Goggins, Academic Support Resources, goggins@umn.edu
* Chris Dinger, Academic Support Resources, ding0057@umn.edu

Copyright (c) 2011 University of Minnesota

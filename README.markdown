About
=====
Shibboleth's Lil Helper (slh) is a tool that automates the generation of Apache/IIS Shibboleth Native Service Provider configuration & metadata files.  It provides several benefits over manually configuring each NativeSp instance/server by:

* __Providing a consistent configuration approach__ you can apply uniformly across all of the servers managed by your organization.
  * Makes deployment automation possible, errors less frequent, and troubleshooting easier.

* __Dividing high level auth specs from actual NativeSp configuration__
  * Programmers can focus on high level goals like "protect files underneath the '/secure' directory on 'somewebsite.com'" rather than grappeling with the bewildering complexity of the NativeSp's interrelated XML files, the Shibboleth protocal, SAML, etc.

* __Providing conceptually simple linear process__ that distills the main steps associated with Shibboleth integration.

* __Verifying metadata consistency__ across sites & hosts associated with particular Shibboletht SP entity_id.

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
------------
* Pre-requisites
  * Ruby: http://www.ruby-lang.org/en/downloads/
  * Rubygems: http://rubygems.org/pages/download

* Via Ruby Gems:
  * gem install shibboleths_lil_helper
  * Then type `slh` -- this provides more detailed/actionable
    documentation

* Via Git: (requires bundler gem)
  * this is how developers/contributors should install the tool
  * git clone ...git://thisrepo... slh
  * cd slh
  * bundle install
  * then add a symlink to bin/slh
    * ln -s bin/slh ~/slh
  * make sure the slh binary is the right one (not a gem one)
    * `which slh`

Before using this tool
----------------------
* Install Shibboleth Native Service Provider Apache/IIS stuff on all of
  the hosts you wish to use shibboleth with.
  https://wiki.shibboleth.net/confluence/display/SHIB2/Installation

Assumptions
-----------
* Each host integrates with a single Identity Provider, not multiple.

* The X509Certificate (sp-cert.pem, sp-key.pem) keys are in their default locations along-side shibboleth2.xml. (you
* The Shibboleth apache module is loaded globally for all vHosts.

Concept
=======

All configuration and authentication specs for all Shibboleth SP instances are specified in a single ruby parseable "shibboleths_lil_helper/config.rb" file.  From these specs, slh is capable of generating all of the required XML files you will need to integrate with a Shibboleth Identify Provider (Idp).

The generation of these XML files happens through a command line tool
called "slh".  Each particular task is broken into sub-commands such as
"initialize", "generate", "verify_metadata", or "generate_metadata" that perform various tasks.

* It all starts with:

    mkdir shibboleth_deployer
    cd shibboleth_deployer
    slh initialize

  This creates a config file with example code you'll need to change to work.

* Go in and edit shibboleths_lil_helper/config.rb to reflect your setup,
  adding
  * entity id
  * idp metadata url
  * hosts, sites, and paths to protect for each for each site


* From here you type:

    slh generate

  which will generate shibboleth2.xml and a couple others
  Now--you go put these files on the hosts they have been generated for.

* The generated shibboleth2.xml will have RequestMap specs that restrict
  access to specified paths you have


* Once you've copied the shibboleth2.xml up to your target hosts, you
  can type:

    slh verify_metadata

  which will tell some of the things that are probably incorrect with
  your setup and how to fix it. (like copying the sp-key.pem and sp-cert.pem keys associated with the :is_key_originator site to all of the other hosts)

* Then, once verify_metadata is showing all green:

    slh generate_metadata

  which generates a metadata file for each strategy/entity id you have
that you can give you your IDP.

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

Additional Docs
===============
* See the stuff in /doc in this project

How to Help
======================

Email Us
----------------------
* Let us know you are interested in using the tool.

* Voice your ideas about questions you have and features you'd like to see.

Authors
=======
* Joe Goggins, Academic Support Resources, goggins@umn.edu
* Chris Dinger, Academic Support Resources, ding0057@umn.edu

Copyright (c) 2011 University of Minnesota

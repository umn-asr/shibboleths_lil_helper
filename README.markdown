About
=====
Shibboleth's Lil Helper (slh) is a tool that automates the generation of Apache/IIS Shibboleth Native Service Provider configuration & metadata files.  It provides several benefits over manually configuring each NativeSp instance/server by:

* __Providing a consistent configuration approach__ applied uniformly across all servers in your organization.

* __Providing conceptually simple linear process__ that distills the main steps associated with Shibboleth integration.

* __Verifying metadata consistency__ across sites & hosts associated with particular Shibboletht SP entity_id.

* __Dividing high level auth specs from actual NativeSp configuration__
  * Programmers can focus on high level goals like "protect files underneath the '/secure' directory on 'somewebsite.com'" rather than grappeling with the bewildering complexity of the NativeSp's interrelated XML files, the Shibboleth protocal, SAML, etc.

__This code is under active development as of 11/12/2011__.  
Please watch this Github repo or periodically check CHANGLOG.markdown to stay to up-to-date.

Use `gem update shibboleths_lil_helper` to get the most current version.

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
  * `gem install shibboleths_lil_helper`
  * Then type `slh` -- this provides more detailed/actionable
    documentation

* Via Git: (requires bundler gem)
  * this is how developers/contributors should install the tool
  * `git clone ...git://thisrepo... slh`
  * `cd slh`
  * `bundle install`
  * then add a symlink to bin/slh (something like below)
    * `ln -s bin/slh ~/slh`
  * make sure the slh binary is the right one (not a gem one)
    * `which slh`

* Install notes:
  * Tool requires nokogiri gem which in-turn requires libxml2, you may
    run into difficulties there: See http://nokogiri.org/tutorials/installing_nokogiri.html if you have problems.

Before using this tool
----------------------
For each host you want to integrate with Shibboleth, do the following and have answers for the questions below.

__Don't try to use this tool until you have followed these instructions for at least one host.__

For each host:

  * __Install Shibboleth Native Service Provider Apache/IIS__
    https://wiki.shibboleth.net/confluence/display/SHIB2/Installation
    Ideally, you should be able to hit a URL like "Shibboleth.ss/Metadata" for each site
    on the host and have it cough out some XML goo. (not a strict
requirement, slh will help you with this later too)

  * What web server is it? IIS or Apache

  * If IIS, what is the site ID?  
    You can find this my clicking "Websites" in IIS and looking at the "Identifier" column for myshinynewwebsite.umn.edu.

  * What is the host name of the computer?  (e.g. somehost.com)

  * What is the site name?  (e.g. myshinynewwebsite.umn.edu)

  * Is authentication required for the entire site or particular directories?

  * Is this URL available for your site?  myshinynewwebsite.umn.edu/Shibboleth.sso/Metadata

  * What is the error support contact email?

  * What is the Service Provider entity ID you'd like to use? 
    A simple convention is to have a dev entity for "development" or "staging" apps and one for production stuff.
    You might consider https://YOUR_ORG.umn.edu/shibboleth/dev_default or https://YOUR_ORG.umn.edu/shibboleth/prod_default


Assumptions
-----------
* Each host integrates with a single Identity Provider, not multiple.
* (for Apache) The Shibboleth apache module is loaded globally for all vHosts.

Concept
-------

All configuration and authentication specs for all Shibboleth SP instances are specified in a single ruby parseable `shibboleths_lil_helper/config.rb` file.  From these specs, slh is capable of generating all of the required XML files you will need to integrate with a Shibboleth Identify Provider (Idp).  The following breaks down the essential steps.


### Initialization
It all starts with

    mkdir shibboleth_deployer
    cd shibboleth_deployer
    slh initialize

This creates a config file with example code you'll need to change to work.

### SP configuration
Edit `shibboleths_lil_helper/config.rb` to reflect your setup:

  * entity id
  * idp metadata url
  * hosts, sites, and paths to protect for each for each site

From here you type:

    slh generate

This creates:

  * shibboleth2.xml
  * idp_metadata.xml
  * shib_apache.conf (if using apache)

for each host for each entity_id.  shibboleth2.xml contains RequestMap, AssertionConsumer server "endpoints" and other goo needed to integrate with an Shib IDP.

Go deploy these config files to you hosts. (the tool provides more details)

### Metadata verification
Verify your metadata data across all hosts:

    slh verify_metadata

Which will tell some of the things that are probably incorrect with
  your setup and how to fix it. (like copying the sp-key.pem and sp-cert.pem keys associated with the `:is_key_originator` site to all of the other hosts)

### Metadata generation
Once verify_metadata is showing all green:

    slh generate_metadata

which generates a metadata file for each strategy/entity id you have
that you can give you your IDP.

Once the IDP has added your metadata, then each site should be able to
respond to 

    Shibboleth.sso/Login

and be happily prompted for login.


Deployment automation
---------------------
Once you have the basic stuff working, you may want to automate
deployment:

    slh capistrano_deploy

will create a config/deploy.rb

See https://github.com/capistrano/capistrano/wiki/ for more details

This requires some initial setup per host and only works well if your
target hosts run SSH (aka default not-IIS setup)

deployment automation example
-----------------------------
We have a private repo called shibboleth\_deployer that includes the shibboleths\_lil\_helper generated config files and uses Capistrano to push these files out target servers and restarts shibd and httpd.  It's usage looks like:

    cap deploy HOST=asr-web-dev4.oit.umn.edu

### Initial setup
For each of our target servers we setup Capistrano to have a clone of
this shibboleth\_deployer repo structured in the standard way:

    ls /etc/shibboleth_deployer
        current
        releases
        shared

Setup symlinks to the appropriate config files within
shibboleth\_deployer from the places the Native Shibboleth SP expects
files to be, e.g:

from the /etc/shibboleth dir

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/shibboleth2.xml shibboleth2.xml

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/idp_metadata.xml idp_metadata.xml

from the /etc/httpd/conf.d dir

    ln -s /etc/shibboleth_deployer/current/shibboleths_lil_helper/generated/apache_shib_test_server/asr-web-dev4.oit.umn.edu/shib_apache.conf shib_apache.conf

How to Help
-----------
* Let us know the issues you are having with the tool via Github Issues.

* Improve the documentation!  The whole purpose of this tool is to
  provide a straight-forward path to setting up a Shibboleth SP.

How to contribute
----------------------
* Fork, implement, issue a pull request for small changes.

* Email us for big ideas or API changes--we'd like to keep this tool
  stable and want to collaborate to identify the right way of
accommodating new features while maintaining backward compatibility.

Contributors
------------
* Joe Goggins, Academic Support Resources, goggins@umn.edu
* Chris Dinger, Academic Support Resources, ding0057@umn.edu

Acknowledgements
----------------
Thanks to these folks for providing feedback and willingness to pilot
the tool.

* David Peterson, Office of Institutional Research
* Debbie Gillespie, Computer Science and Engineering
* Eva Young, Office of Institional Compliance
* Josh Buysse, CLA Office of Information Technology
* Aaron Zirbes, Environmental Health Sciences


Copyright (c) Regents of the University of Minnesota

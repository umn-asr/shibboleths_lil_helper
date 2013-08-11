About
=====
Shibboleth's Lil Helper (slh) is a tool that automates the generation of Apache/IIS Shibboleth Native Service Provider configuration & metadata files.  It provides several benefits over manually configuring each NativeSp instance/server by:

* __Providing a consistent configuration approach__ applied uniformly across all servers in your organization via one easy-to-read config file describing shib config across X web servers (IIS and Apache), Y sites, and Z directory paths.

* __Providing conceptually simple linear process__ that distills the main steps associated with Shibboleth integration.  
  1. initialize a config.rb file
  2. edit slh config.rb file
  3. generate shib2.xml (and deploy to web server hosts)
  4. verify sp metadata correctness
  5. generate metadata
  6. send metadata to idp
  7. verify all is well

* __Dividing high level auth specs from actual NativeSp configuration__
  * Programmers can focus on high level goals like "protect files underneath the '/secure' directory on 'somewebsite.com'" rather than grappeling with the bewildering complexity of the NativeSp's interrelated XML files, the Shibboleth protocal, SAML, etc.


Assumptions
-----------
* __shibboleth-2.4.3 is installed on your target hosts__.
  Versions greater than this should work too, but have not been tested.
* Each web server host integrates with a single Identity Provider, not multiple.
* All sites on a particular web server host use the same Service
  Provider Entity ID.
* (for Apache) The Shibboleth apache module is loaded globally for all
  vHosts.  (This doesn't mean that it requires auth globally--just available, see lib/slh/templates/shib_apache.conf.erb for what this looks like).

Installation
------------
* Pre-requisites
  * Ruby: http://www.ruby-lang.org/en/downloads/
  * Rubygems: http://rubygems.org/pages/download

* Via Ruby Gems:
  * `gem install shibboleths_lil_helper`
  * Then type `slh` -- this provides more detailed/actionable
    documentation

* Via Git: (for developers/contributors)
  * this is how developers/contributors should install the tool
  * `git clone ...git://thisrepo_or_a_fork... slh`
  * `cd slh`
  * `bundle install`
  * then add a symlink to bin/slh (something like below)
    * `ln -s bin/slh ~/slh_local`
  * run commands on your test config.rb with `slh_local generate` or
    `slh_local generate_metadata`, etc

* Install notes:
  * Tool requires nokogiri gem which in-turn requires libxml2, you may
    run into difficulties there: See http://nokogiri.org/tutorials/installing_nokogiri.html if you have problems.
  * Doesn't work w JRuby, probably all versions, 1.6.7 confirmed to not
    work.

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

Usage
-----

All configuration and authentication specs for all Shibboleth SP instances are specified in a single ruby parseable `shibboleths_lil_helper/config.rb` file.  From these specs, slh is capable of generating all of the required XML files you will need to integrate with a Shibboleth Identify Provider (Idp).  The following breaks down the essential steps.

### 1. __Initialize a config.rb file__

    mkdir shibboleth_deployer
    cd shibboleth_deployer
    slh initialize

  This creates a config file with example code you'll need to change to work.

### 2. edit `shibboleths_lil_helper/config.rb`
The generated config.rb contains instructions and examples of valid
configuration options to set your:
  * sp_entity_id
  * idp_metadata_url : the URL (NOT the idp entity ID) for you IDP's metadata
  * strategies, hosts, sites, and paths to protect

### 3. Generate shibboleth2.xml and deploy to web server hosts
In the directory one up from "shibboleths_lil_helper" (in this case shibboleth_deployer), type

    slh generate

This creates files for each web server host:

  * shibboleth2.xml
  * idp_metadata.xml (this is simply a copy of the IDP metadata at :idp_metadata_url
  * shib_apache.conf (if using apache)

shibboleth2.xml contains a <RequestMap> and other goo needed to integrate with an Shib IDP to reflect the sites and paths your want protected.

You must deploy these files to each host and restart the shib
daeman/service and apache/IIS.

You must also arbitrarily __pick one particular site__ in each strategy to `set :is_key_originator,true` for, if you see this more in a strategy, it will NOT WORK.  (also, don't set it to false, just remove the line in all but one site)

`set :is_key_originator, true` tells slh that this site has the authoriative X509Certificate (in the SP metadata) that all other sites should match against (used in the verify_metadata command).

It implies that each host in your strategy has the same sp-key.pem and sp-cert.pem files as the host where the "is_key_originator" site lives.  

It also implies that, when you setup a new web server host: copy the sp-key and sp-cert files from this "is_key_originator" host to the new host.

### 4. Verify SP metadata correctness
Once you've deployed you shibboleth2.xml, idp_metadata.xml, shib_apache,
and sp-key, and sp-cert to all hosts, you can

Verify your metadata data across all hosts with:

    slh verify_metadata

This command will provide useful output and instructions to get your SP
metadat setup correctly.

This command and generate_metadata rely on URLs like `somesite.com/Shibboleth.sso/Metadata`

being publically available.  If this command is erroring out, its likely
due to the fact that one or more sites does not expose this URL (and
likely requires a change to shibboleth2.xml, i.e. tweak config.rb, `slh generate`, and redeploy to server).


### 5. Generate SP metadata
If verify_metadata is not showing any errors, you can proceed to

    slh generate_metadata

which generates an SP metadata file for each SP entity id in in a file
like:

    shibboleths_lil_helper/generated/<STRATEGY_NAME>/<STRATEGY_NAME>_sp_metadata_for_idp.xml

__This SP Metadata file MUST BE INSTALLED on the IDP to proceed!!!__
Typically this is done by emailing the file to your identity management
team

### 6. Send SP metadata to IDP folks
Send the <STRATEGY_NAME>_sp_metadata_for_idp.xml to your IDP folks.

### 7. Verify all is well
Hit somesite.com/Shibboleth.sso/Login and be happily prompted for login.


Deployment automation (on Unix/Apache)
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
__Only works on Unix/Apache__

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

Staying up-to-date
------------------
__This code is under active development__.

* Use `gem update shibboleths_lil_helper` to get the most current version.
* See CHANGLOG.markdown for the changes associated with each gem
  release.

How to help/contribute
-----------
* To suggest enhancements or changes let us know via Github Issues (preferred) or email.

* To share your experience, tricks, nuances, gotchas, and perspectives, please see and add to the [Github Wiki](https://github.com/umn-asr/shibboleths_lil_helper/wiki).

* To add features or fix stuff yourself: fork, implement, issue a pull request.

Author
------
* Joe Goggins, Academic Support Resources, goggins@umn.edu
     
Copyright (c) 2012 Regents of the University of Minnesota

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
* `slh create_strategy asr_default`
* edit asr_default.rb, anywhere you see "TODO_CHANGE" in particular
* `slh generate_config asr_default`
* copy the generated shibboleth config files to the remote server, and
  restart shibd

Usage with Capistrano
=====================
TODO


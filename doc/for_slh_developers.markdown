---
Find the version of shibboleth you are currently running on a host
  rpm -qi shibboleth





FOR SHIBBOLETHS_LIL_HELPER DEVELOPERS
---
If you want to inspect what is happening ANYWHERE in the code (including
ERB templates in <% %> tags)
Put
  debugger
anywhere in the code, and run:
  rdebug slh <SOME_COMMAND>

An interactive Ruby shell will pop up and you can hit
  e <THE_NAME_OF_THE_VAR>


---
Assuming
  * you are in the root dir of a git clone of shibboleths_lil_helper
  * you have already run initialize and therefore have a
    "shibboleths_lil_helper" sub-dir within the 
     shibboleths_lil_helper repo

You can get at an irb session loaded with your config stuff like this:
  rake console

  # then once in console
  require 'shibboleths_lil_helper'
  Slh.load_config 

  # Then tinker with config stuff stemming from
  Slh.strategies

DEV_WISH_LIST: `rake console` should do all of these things for you, I
think this will involve looking at jeweler's "console" rake task and
figuring out how to add files to load and ruby to run before entering
the irb session

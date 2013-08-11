2.0.0
=====
* Complete re-write/re-think of the tool using test driven
  development to verify intended behavior, see doc/v2.0.0_feature_list.md for details of features.
  Most of the DSL syntax is the same.

1.0.9
=====
* Mostly a bunch of documentation improvements.

1.0.8
=====
* Don't remove the entire "generated" directory every time "slh generate" is run.
  Rather, just over-write existing files.  This is a simple change that
  eliminates tons of white-noise from a diff of before and after.  This
is particularly useful for folks who are using slh with source control (which everyone should!!)
  Also useful when doing something like `slh generate --filter=somehostname.com`, which
  will only generate new shib2.xmls for these hosts.

1.0.7
=====
* <Logout>SAML2 Local</Logout> to <Logout>Local</Logout>.  Was
  misleading, SAML2 log-out not supported.

1.0.6
=====
* Moved the wrong documentation for set :site_id into the correct place in
  default generated config.rb (under for_site, not for_iis_host or for_apache_host)
* Fixed the load file so it would work in ruby 1.9.3

1.0.5
=====
* Relaxed dependency on ActiveSupport from ~> 3.0.9 to >= 3.0.9
* Made verify_metadata not exit on fatal error if Shibboleth.sso does
  not exist
* Moved documentation into its own string Slh::Cli.documentation
* Specified shibboleth-2.4.3 is installed on your target hosts in README
* Made all github links about this project point to http://github.com/umn-asr/shibboleths_lil_helper, its final resting point.

1.0.4
=====
* Fixed an evil bug in Slh.clone_strategy_for_new_idp that
  would make the newly cloned strategy clobber the existing strategy.

1.0.3
=====
* Made at least one `protect` statement required for each site
* Improved the output of `slh generate` to tell the user where to place
  the files
* Overhauled the README and the default config.rb created on `slh initialize`

1.0.2
=====
* Added the acl bit to shibboleth2.xml like <Handler type="Status" Location="/Status" acl="127.0.0.1"/>
  to improve security to comply with how the default shib distro works.

1.0.1
=====
* Added `set :is_key_originator, true` to the default config.rb


1.0.0
=====
* Initial release


Nuances
=======

Order matters with "for_site" (sort of)
---------------------------
* When running 'slh metadata', the first site declared under "for_host"
  (in shibboleths_lil_helper/config.rb), is used when as the remote target to hit /Shibboleth.sso/Metadata.
  This true anywhere a remote request is needed to be made for one of
your hosts

  Therefore, if the first site is broken but others are not--switching the order so the first one works will
  make the metadata comparing work.


This document is both for Shibboleth's Lil Helper developers and folks
setting up the Shibboleth SP.  It was created to simply catelog the many
different gotchas that were solved while building this tool


---
QUESTION
	If you are at 
	  https://shib-php-test.asr.umn.edu/secure
	  and goto
	  https://shib-php-test.asr.umn.edu/Shibboleth.sso/Login
	  it redirects to
	  https://shib-php-test.asr.umn.edu
	How to make it redirect to /secure?

ANSWER
  See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPSessionCreationParameters
  Goto 
https://shib-php-test.asr.umn.edu/Shibboleth.sso/Login?target=https%3A%2F%2Fshib-php-test.asr.umn.edu%2Fsecure

---
QUESTION
  How do I logout and redirect to the current page
If you are on 
  https://shib-php-test.asr.umn.edu/secure
and want to log out and redirect back to this same apge

ANSWER
  See https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLogoutInitiator
  You go to this page:
    https://shib-rails2-test.asr.umn.edu/Shibboleth.sso/Logout?return=https%3A%2F%2Fshib-php-test.asr.umn.edu%2Fsecure


---
QUESTION
Where is the specs and examples on how to do setup the RequestMap correctly?
https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapHowTo
https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapPath
https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPRequestMapPathRegex


QUESTION:
Where is the XML specs for what constitutes valid Metadata?
ANSWER
http://docs.oasis-open.org/security/saml/v2.0/saml-metadata-2.0-os.pdf
You can also find specification details at schemacentral.com (e.g.
http://www.schemacentral.com/sc/ulex20/e-md_SPSSODescriptor.html)

QUESTION

If HTTP headers are an issue in Apache, why aren't they in IIS?

ANSWER

It seems like the ONLY way to use the Native SP with IIS is HTTP headers.

TODO.


---
Question
I've have apache and shib installed and configured for a particular IDP and out on a target server, and when I go to Shibboleth.sso/Login, I get "shibsp::ConfigurationException", whats wrong?

Answer:
One likely issue is that one of the files  referenced from shibboleth2.xml (i.e. attribute-map.xml), does not exist OR is not referenced as an absolute path in the case where shibboleth is not installed at the default location of /etc/shibboleth.


QUESTION:
When I hit something.com/Shibboleth.sso/Metadata on IIS I get:
Shibboleth Error
Shibboleth Extension not configured for web site (check ISAPI mappings in SP configuration).

how do I fix this?
ANSWER:

You probably just need to restart IIS and shibd.
but you should also check this out:
https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPWindowsIIS7Installer

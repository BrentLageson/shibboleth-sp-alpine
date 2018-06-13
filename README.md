# Introduction
This image contains a full operative Shibboleth Service Provider 2.6.1 in Docker Alpine.

It's been dockerized following the installation instructions that you can find at [Shibboleth](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxSourceBuild)

# Purpose
The purpose of this image is to give a starting point from which you could create a customized SP image following your own requirements.

# Paths
You can customize several behaviours looking at Shibboleth documentation and finding the appropriated paths in:

* _/etc/shibboleth/metadata_: here you can put your IDP metadata, in order to configure the SP against it
* _/etc/shibboleth_: here are all the configuration files and certificates that you can customize
* _/usr/local/bin/httpd-shibd-foreground_ : this is the script that launches apache and shibboleth, and that should be launched when
 you run the generated image.
* _/var/www/html_ : base path for free access html pages
* _/var/www/html/secure_ : base path for secured part of the site you want to protect.
 
# Disclaimer
I've successfully customized a SAML 2.0 SP provider, customizing both Apache and Shibboleth to fit my requirements, being able to do 
 a SSO and SLO against a Shibboleth IDP. I haven't used this image for professional purposes. 

 
 


chef-runonce
============

A startup script for a newly cloned VM to install chef, register itself
with the chef server, and apply an initial run list.  It essentially is
an automated run of knife bootstrap.

It's designed to be run once as a start up script, after customization,
and remove itself when completed.

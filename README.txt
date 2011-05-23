== README for PerlUnit website

This README is for the website branch of the Git repository.  If you
are seeing it in a code browser and wanted code, please switch to the
master branch.

== Website features / to do

* pod2html.  CPAN does that for releases so we don't need to.

* "News".  A column of boxes is more stable, portable & reliable than
  the SF.net feature (which became mysteriously empty some time in the
  last six years).

* Small FAQ section would be a good idea.

== Updating

 mkdir W
 sshfs $SFLOGiN@web.sourceforge.net:/home/project-web/perlunit W

 (cd W; git fetch; git status)
 # apply eyeball to output - website should be fast-forwardable
 (cd W; git pull)

 # no longer recommending 'chmod g+w' since the SF magical filesystem
 # seems to take care of permissions in some non-pure-POSIX way?

 fusermount -u W
 rmdir W

== Copyright

The website is copyright (c) 2001,2005,2011 the authors of the
PerlUnit project.  It is distributed with the project code, under the
same terms, despite being in a separate branch in version control.

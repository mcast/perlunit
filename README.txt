== README for PerlUnit website

This README is for the website branch of the Git repository.  If you
are seeing it in a code browser and wanted code, please switch to the
master branch.

== Website features / to do

* pod2html.  CPAN does that for releases so we don't need to.

* "News".  A column of boxes is more stable, portable & reliable than
  the SF.net feature (which became mysteriously empty some time in the
  last six years).

== Updating: by sshfs

The 'origin' is an absolute pathname on the SourceForge filesystem, so
you must push to the clone, or reconfigure with a git/ssh URL, or
contrive for your desktop to resolve /home/scm_git/...

This also probably thrashes the index.  Not so important for just
three files.

 mkdir W
 sshfs $SFLOGIN@web.sourceforge.net:/home/project-web/perlunit W

 git push W website:origin/website
 (cd W; git merge --ff-only origin/website; git status)

 # no longer recommending 'chmod g+w' since the SF magical filesystem
 # seems to take care of permissions in some non-pure-POSIX way?

 fusermount -u W
 rmdir W

== Updating: doing it over there

This is simple and reliable but not very efficient.

 ssh $SFLOGIN,perlunit@shell.sourceforge.net create
 ssh $SFLOGIN@shell.sourceforge.net 'cd /home/project-web/perlunit && git pull --ff-only'
 ssh $SFLOGIN@shell.sourceforge.net shutdown

== Copyright

The website is copyright (c) 2001,2005,2011 the authors of the
PerlUnit project.  It is distributed with the project code, under the
same terms, despite being in a separate branch in version control.

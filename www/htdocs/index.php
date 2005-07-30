<?php
// (hacked from) Default Web Page for groups that haven't setup their page yet
// Please replace this file with your own website
//
// $Id: index.php,v 1.6 2005-07-30 20:41:38 mca1001 Exp $
//
$headers = getallheaders();
?>
<HTML>
<HEAD>
<TITLE>PerlUnit: unit testing framework for Perl</TITLE>
<LINK rel="stylesheet" href="http://sourceforge.net/sourceforge.css" type="text/css">
<base href="http://PerlUnit.sourceforge.net/"><!-- so I can test my local copy -->
</HEAD>

<BODY bgcolor=#FFFFFF topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0">

<!-- top title table -->
<TABLE width="100%" border=0 cellspacing=0 cellpadding=0 bgcolor="" valign="center">
  <TR valign="middle" bgcolor="#eeeef8">
    <TD>
      <!-- SF logo as requested in the SF docs -->
      <A href="http://sourceforge.net"><IMG src="http://sourceforge.net/sflogo.php?group_id=2653&type=1" width="88" height="31" border="0" alt="SourceForge Logo"></A>
    </TD>
    <td align="center"><h1>The &quot;PerlUnit&quot; unit testing framework</h1></td>
    <TD><!-- right of logo -->
      <a href="http://www.valinux.com"><IMG src="http://sourceforge.net/images/va-btn-small-light.png" align="right" alt="VA Linux Systems" border="0" width="105" height="31"></A>
    </TD><!-- right of logo -->
  </TR>
  <TR><TD bgcolor="#543a48" colspan="3"><IMG src="http://sourceforge.net/images/blank.gif" height="2" vspace="0"></TD></TR>
</TABLE>
<!-- end top title table -->



<p>If you don't know what a unit testing framework is or why you would
   want one, the <a href="#related">links</a> below will fill you in.

<p>If you want a unit testing framework for perl, the details are in
   the <a href="http://sourceforge.net/projects/perlunit/">project
   summary page</a>. Here are some shortcuts to the important bits:
</p>

<ul>

<li>Grab the current release from our SourceForge download area [
    <a href="http://sourceforge.net/project/showfiles.php?group_id=2653">
    HTTP</a> | <a href="ftp://ftp.sourceforge.net/pub/sourceforge/perlunit/">FTP</a> ] or
    <a href="http://search.cpan.org/search?dist=Test-Unit">from CPAN</a>.

<p>
<li>We have two <a href="http://sourceforge.net/mail/?group_id=2653">mailing lists</a>,
    with archives:
    <ul>
    <li><a href="http://sourceforge.net/mailarchive/forum.php?forum_id=2442">
        perlunit-devel</a> (low volume discussion)
    <li><a href="http://sourceforge.net/mailarchive/forum.php?forum_id=2441">
        perlunit-users</a> (this list is quiet, if not silent)
    </ul>
    There are also some web-based forums but we've mostly abandoned
    them because we don't like the user interface.

<p>
<li>Browse the
    <a href="http://cvs.sourceforge.net/viewcvs.py/perlunit/">

    CVS repository</a> to see the current state of our files.  A quick
    outline of what's there:

  <dl>
   <dt>src/Test-Unit</dt>
   <dd>This is the source for the distributed package.</dd>

   <dt>src/Test-Unit-0.06, src/UnitTests, src/XUnit-0.01, src/api</dt>
   <dd>Old layouts of the project, everything is in the Attic.  Ignore.</dd>

   <dt>src/junit3.2</dt>
   <dt>src/tools</dt>
   <dd>This is project history - what Brian used to start the project.</dd>

   <dt>www/</dt>
   <dd>Contains the website
   <a href="http://perlunit.sourceforget.net/">http://perlunit.sourceforget.net/</a>,
   no released files or source.</dd>
  </dl>

</ul>

<p>Most of the documentation lives in <code>POD</code> format in the
   code, which is very convenient if the package is installed.
<br>
   We plan to make it available here via <code>pod2html</code> at some
   point (suggestions for a good tool would be welcome), but in the
   mean time you can browse the <code>POD</code> for the current
   release via
   <a href="http://search.cpan.org/search?dist=Test-Unit">CPAN</a>, as
   above.

</p>

<p><a name="related">Links to related sites:</a>
<ul>
<li><a href="http://www.xProgramming.com/">http://www.xProgramming.com/</a>,
    Extreme Programming site
<li><a href="http://JUnit.sourceforge.net/">http://JUnit.sourceforge.net/</a>,
    Java unit testing framework from which Perlunit was cloned
<li><a href="http://c2.com/cgi/wiki?PerlUnit">http://c2.com/cgi/wiki?PerlUnit</a>,
    A forest of data at the Wiki Wiki Web
</ul>

<p align="right"><small>Last update:
$Date: 2005-07-30 20:41:38 $
</small></p>


</BODY>
</HTML>

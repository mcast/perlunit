<?php
// (hacked from) Default Web Page for groups that haven't setup their page yet
// Please replace this file with your own website
//
// $Id: index.php,v 1.4 2001-04-27 20:01:45 mca-gdl Exp $
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

<!-- center table -->
<TABLE width="100%" border="0" cellspacing="5" bgcolor="#FFFFFF" cellpadding="5" align="center">
  <TR>
    <TD>

<br>

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
    <li><a href="http://www.geocrawler.com/redir-sf.php3?list=perlunit-devel">
        perlunit-devel</a> (low volume discussion)
    <li><a href="http://www.geocrawler.com/redir-sf.php3?list=perlunit-users">
        perlunit-users</a> (this list is quiet, if not silent)
    </ul>
    There are also some web-based forums but we've mostly abandoned
    them because we don't like the user interface.

<p>
<li>If you are using or thinking about using Perlunit, we would be
    grateful if you filled in our
    <a href="http://sourceforge.net/survey/survey.php?group_id=2653&survey_id=11342">
    User Background survey</a> so we know a little bit more about our
    audience.
<p>
    If you've already filled it in, feel free to have another go and
    change your answers. The survey won't tell you what your replies
    were last time, but it does enforce one-vote-per-account.
<p>
    Finally, I did a bad thing - I added two questions to the survey
    on 27<sup>th</sup> April 2001, despite the warnings not to. Since
    we only have six answers so far, it doesn't make too much
    difference... but <strong>if you're one of the other five people
    then there are more questions to answer!</strong> Sorry about
    this. I won't do it again. <small>[mca]</small>

<p>
<li>Browse the
    <a href="http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/perlunit">
    CVS repository</a> to see the current state of our files.

</ul>

<p>Most of the documentation lives in <code>POD</code> format in the
   code, which is very convenient if the package is installed.
<br>
   We plan to make it available here via <code>pod2html</code> at some
   point, but in the mean time you can browse the <code>POD</code> for
   the current release via

   <a href="http://search.cpan.org/search?dist=Test-Unit">CPAN</a>, as
   above.

</p>

<p><a name="related">Links to related sites:</a>
<ul>
<li><a href="http://www.xProgramming.com/">http://www.xProgramming.com/</a>,
    Extreme Programming site
<li><a href="http://JUnit.sourceforge.net/">http://JUnit.sourceforge.net/</a>,
    Java unit testing framework from which Perlunit was cloned
</ul>

<p align="right"><small>Last update:
$Date: 2001-04-27 20:01:45 $
</small></p>

    </TD>
  </TR>
</TABLE>
<!-- end center table -->

<!-- footer table -->
<TABLE width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="737b9c">
  <TR>
    <TD align="center">
    <FONT color="#ffffff"><SPAN class="titlebar"><small>
    All trademarks and copyrights on this page are properties of their
    respective owners. Forum comments are owned by the poster. The
    rest is copyright ©1999-2000 VA Linux Systems, Inc.
    </small></SPAN></FONT>
    </TD>
  </TR>
</TABLE>
<!-- end footer table -->
</BODY>
</HTML>

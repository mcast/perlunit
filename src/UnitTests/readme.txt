  To exercise the asserion test modules, run "perl NeverPass.pl" and
  "perl AlwaysPass.pl".  The output of NeverPass.pl should be an error
  message for every test.  AlwaysPass.pl should produce no errors.

  To customize for a unit test for a particular module, use NeverPassTestCase.pm
  or AlwaysPassTestCase.pm as templates. run shows how to set up a test suite.
  Each test should have a name, beginning with "test_".


  CHANGES:

  In response to a suggestion from Colin Jitlal, I added a routine,
  build_suite, to UnitTestSuite.pm.  build_suite automatically builds a
  suite from functions that start with "test_". The new code requires
  Devel::Symdump, available from cspan.

  I have also changed the root path from Bio::UnitTests:: to UnitTests::

IN NO EVENT SHALL THE AUTHOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF
THIS CODE, EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

THE AUTHOR SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE.  THE CODE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
AND THERE IS NO OBLIGATION WHATSOEVER TO PROVIDE MAINTENANCE,
SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

#!/gec/local/bin/perl

# Convert, roughly, java to perl. Javadoc is preserved
# and the code immediately following javadoc is converted
# into class/method stubs.
# This is one unholy hack. Dont ever think about 'maintaining' it.

convert_dir('.');

sub convert_dir {
  my $dir=shift;
  $context=$dir; # context isnt local. dir is.
  $context=~s/^\.\/?//;
  $context=~s/\//::/;
  if ($context ne "") {$context.="::"}
  my @files;
  opendir(DIR,$dir) or do { print "Couldnt open $dir.\n"; return; };
  @files=grep { $_ ne "." and $_ ne ".." } readdir(DIR); 
  closedir(DIR);
  foreach $file (@files) {
	if (-d "$dir/$file") {
	  print "Cd'ing to $dir/$file\n";
	  convert_dir("$dir/$file");
	} elsif ($file=~/\.java$/) {
	  print "Converting $dir/$file\n";
	  convert_file("$dir/$file");
	} else {
	  #print "Ignoring $dir/$file\n";
	}
  }
}

sub convert_file {
  my $file=shift;
  $state=0;
  $list="";
  open(IN,"$file") or do { print "Couldnt open $file.\n"; return; };
  $file=~s/\.java/.pm/;
  open(OUTFILE,">$file") or 
	do { print "Couldnt write $file.\n"; return; };
  print OUT "=head1 $file\n\n=cut\n\n";
  while($_=<IN>) {
	# line of code immediately after javadoc comment.
	$state==2 && &translate_java($_);
	# end of javadoc comment. Next line may need translation.
	/\*\// && $state==1 && &end_comment;
	$state==1 && &translate_javadoc($_);
	# start of javadoc comment.
	/\/\*\*/ && &begin_comment;
  }
}

sub begin_comment {
  $state=1;
  print OUTFILE "\n=head2 XXXX\n\n";
}

sub end_comment {
  if ($list ne "") {
	print OUTFILE "\n=back\n";
	$list="";
  }
  print OUTFILE "\n=cut\n\n";
  $state=2;
}

sub translate_javadoc {
  my $comment=shift;
  # get rid of leading javadoc cruft.
  $comment=~s/^\s*\*\s*//;
  $comment=~s/\s*$//;
  if ($comment=~/\@(\w+)\s+(.*)/) {
	if ($list ne $1) {
	  $list=$1;
	  print OUTFILE $1."s:\n\n=over 4\n";
	}
	if ($list eq "param") {
	  $comment=$2;
	  $comment=~/(\w+)\s*(.*)/;
	  print OUTFILE "\n=item $1\n\n$2\n";
	} else {
	  print OUTFILE "\n=item *\n\n$2\n";
	}
  } elsif ($list ne "") {
	print OUTFILE "\n=back\n";
	$list="";
  } else {
	print OUTFILE $comment."\n";
  }
}  

sub translate_java {
  my $code=shift;
  return if ($code=~/^\s*$/);

  $code=~s/^\s*//;  
  $code=~s/\s*$//;
  if ($code=~/(\w+)\(/) {
	print OUTFILE "sub $1 {\n}\n";
  } elsif ($code=~/(class|interface)\s(\w+)/) {
	print OUTFILE "package $context$2;\n";
	if ($code=~/(extends|implements)\s(\w+)/) {
	  print OUTFILE "use $2;\nuse vars qw(\@ISA);\n\@ISA=qw($2);\n";
	}
  } else {
	print OUTFILE "$code\n";
  }
  $state=0;
}

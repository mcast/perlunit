#!/usr/bin/perl
#
# Copyright (C) 2000 Brian Ewins
#
# $Id: TkTestRunner.pm,v 1.2 2000-02-23 11:04:59 ba22a Exp $
#


package Test::Unit::TkTestRunner;
use base qw(Test::Unit::TestListener);
use Tk;
use Test::Unit::TestResult;
use Benchmark;
use strict;

# The pass,fail, error methods are up front here 'cos they're
# the ones that are callbacks for the test suite. The rest of them
# are pretty much ignorable.
# This doesnt resize properly yet, which sucks. The labelled
# entry boxes are *awful*. I'm going to switch back to the packer 
# and try to get the layout 'right' using frames.

### TestListener methods.

sub plan{
  my $self=shift;
  $self->{'planned'}=shift;
}

sub start_test {
}

sub add_pass {
  my $self=shift;
  my ($test,$exception)=@_;
  $self->{'passes'}++;
  $self->update();
}

sub add_failure {
  my $self=shift;
  $self->add_message(@_);
  $self->{'failures'}++;
  $self->update();
}

sub add_error {
  my $self=shift;
  $self->add_message(@_);
  $self->{'errors'}++;
  $self->update();
}

sub end_test {
}

# Normal methods follow...
sub new {
  my $self=bless {}, shift;
  # fill in the test name from the command line if possible.
  $self->{'testname'}=shift; 
  map {$self->{$_}=0} 
  qw(runs errors failures passes start history_size);
  $self->{'status'}='STOPPPED';
  $self->{'history'}=[];
  # Lay the window out....
  my $main=MainWindow->new(-title=>'PerlUnit Test Harness');
  my $history_list=$main->
    BrowseEntry(-label=>"Test name",
				-width=>40,
				-variable=>\$self->{'testname'},
				-listcmd=> sub {$self->populate_history();});
  $history_list->form(-left=>['%0'],-top=>['%0']);
  my $btn_run=$main->Button(-text => "Run",
		-command => sub {$self->run()}
	       )
	->form(-right=>['%100'],-top=>['%0']);
  my $lab_runs=$main->
	LabEntry(-label=>'Runs:',
			 -text=> \$self->{'runs'},
			 -state=>'disabled',
			 -width=>12, 
			 -relief=>'flat',
			 -justify=>'left'
			)
	  ->form(-left=>['%0'],-top=>[$history_list]);
  my $lab_pass=$main
	->LabEntry(-label=>'Passed:',
			   -text=>\$self->{'passes'},
			   -state=>'disabled',
			   -width=>12, 
			   -relief=>'flat',
			   -justify=>'left'
			)
	  ->form(-left=>[$lab_runs],-top=>[$history_list]);
  my $lab_fail=$main
	->LabEntry(-label=>'Failures:',
			   -text=>\$self->{'failures'},
			   -state=>'disabled',
			   -width=>12, 
			   -relief=>'flat',
			   -justify=>'left'
			)
	  ->form(-left=>[$lab_pass],-top=>[$history_list]);
  my $lab_err=$main
	->LabEntry(-label=>'Errors:',
			   -text=>\$self->{'errors'},
			   -state=>'disabled',
			   -width=>12, 
			   -relief=>'flat',
			   -justify=>'left'
			)
	  ->form(-left=>[$lab_fail],-top=>[$history_list]);
  # There is no gauge control. Make do by having a 
  # coloured rectangle on a Tk::Canvas.
  my $gauge=$main
	->ArrayBar(-width=>30,
			   -length=>400,
			   -relief=>"sunken",
			   -variable => [0,0,0],
			   -colors=> ['green','red','gray55'],
  			   -borderwidth=>2
			  )
	  ->form(-left=>['%0'],-top=>[$btn_run,50]);
  my $listbox=$main
	->Scrolled('Listbox',
			   -scrollbars=>'e',
			   -width=>60,
			   -height=>15)
	  ->form(-fill=>'both',-top=>[$gauge]);
  my $btn_stop=$main
	->Button(-text => 'Stop',
			 -command => sub { $self->cancel() }
			)
	  ->form(-left=>['%0'],-top=>[$listbox]);
  my $btn_view=$main
	->Button(-text => 'View Details',
			 -command => sub {$self->view_details()}
			)
	  ->form(-left=>[$btn_stop],-top=>[$listbox]);
  my $btn_quit=$main
	->Button(-text => 'Quit',
			 -command => [$main => 'destroy']
			)
	  ->form(-right=>['%100'],-top=>[$listbox]);
  my $lab_time=$main
	->Entry(
			-text=>\$self->{'elapsed'},
			-state=>'disabled',
			-width=>50, 
			-relief=>'raised')
	  ->form(-right=>['%100'],-top=>[$btn_quit]);
  my $lab_time=$main
	->Entry(
			-text=>\$self->{'status'},
			-state=>'disabled',
			-width=>10, 
			-relief=>'raised')
	  ->form(-left=>['%0'],-top=>[$btn_quit]);
  $self->{'main'}=$main;
  $self->{'gauge'}=$gauge;
  $self->{'listbox'}=$listbox;
  $self->{'history_list'}=$history_list;
  return $self;
}  

sub add_message {
  my $self=shift;
  my ($test,$exception)=@_;
  $self->{'listbox'}->insert("end",$test->name());
  push @{$self->{'detail'}},$exception;
}

sub clear_messages {
  my $self=shift;
  $self->{'listbox'}->delete(0,"end");
  $self->{'detail'}=[];
}


sub update {
  my $self=shift;
  my $bad=$self->{'failures'}+$self->{'errors'};
  my $total=$bad+$self->{'passes'};
  my $todo=($total>$self->{'planned'})?0:$self->{'planned'}-$total;
  $self->{'gauge'}->value($self->{'passes'},$bad,$todo);
  $self->{'elapsed'}=timestr(timediff(new Benchmark(),$self->{'start'}),'nop');
  # force entry into the event loop.
  # this makes it nearly like its threaded...
  #sleep 1;
  if ($self->{'status'} eq 'STOPPING') {
	$self->{'status'}='STOPPED';
	die "Cancelled"; #fix this later.
  }
  $self->{'main'}->update();
}

sub cancel {
  my $self=shift;
  if ($self->{'status'} eq 'RUNNING') {
	$self->{'status'} = 'STOPPING';
  }
}

sub run {
  my $self=shift;
  # if the test just run isn't the one at the top of the list,
  # then add it.
  $self->{'history'}=[$self->{'testname'},
		      grep { $_ ne $self->{'testname'}} 
		      (@{$self->{'history'}})[0..9]];
  $self->{'runs'}++;
  map {$self->{$_}=0} qw(errors failures passes);
  $self->clear_messages();
  $self->{'start'}=new Benchmark();
  $self->update();
  $self->{'suite'}=Test::Unit::TestLoader::load($self->{'testname'});
  $self->{'result'}=Test::Unit::TestResult->new();
  $self->{'planned'}=$self->{'suite'}->count_test_cases();
  $self->{'result'}->add_listener($self);
  $self->{'start'}=new Benchmark();
  $self->{'status'}='RUNNING';
  $self->{'suite'}->run($self->{'result'});
  $self->{'status'}='STOPPED';
  $self->update();
}

sub populate_history {
  my $self=shift;
  my $h=$self->{'history_list'};
  $h->delete(0,$self->{'history_size'});
  foreach (@{$self->{'history'}}) {
    $h->insert("end",$_);
  }
  $self->{'history_size'}=scalar @{$self->{'history'}};
}

sub view_details {
  # pop up a text dialog containing the details.
  my $self=shift;
  my $dialog=$self->{'main'}->DialogBox(-title=>'Details',-buttons=>['OK']);
  #my $frame=$dialog->add();
  my $text=$dialog->add("Scrolled","ROText", -width=>80, -height=>20)->pack;
  $text->insert("end",$self->{'detail'}->[$self->{'listbox'}->curselection]
			   ->stacktrace());
  $dialog->Show();
}

package Tk::ArrayBar;
# progressbar doesnt cut it.
# This expects a variable which is an array ref, and
# a matching list of colours. Sortof like stacked progress bars.
# Heavily - ie almost totally - based on the code in ProgressBar.
use Tk;
use Tk::Canvas;
use Carp;
use strict;

use base qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'ArrayBar';

sub ClassInit {
    my ($class,$mw) = @_;

    $class->SUPER::ClassInit($mw);

    $mw->bind($class,'<Configure>', ['_layoutRequest',1]);
}


sub Populate {
    my($c,$args) = @_;

    $c->ConfigSpecs(
	-width    => [PASSIVE => undef, undef, 0],
	'-length' => [PASSIVE => undef, undef, 0],
	-padx     => [PASSIVE => 'padX', 'Pad', 0],
	-pady     => [PASSIVE => 'padY', 'Pad', 0],
	-colors   => [PASSIVE => undef, undef, undef],
	-relief	  => [SELF => 'relief', 'Relief', 'sunken'],
	-value    => [METHOD  => undef, undef, undef],
	-variable => [PASSIVE  => undef, undef, [0]],
	-anchor   => [METHOD  => 'anchor', 'Anchor', 'w'],
	-resolution
		  => [PASSIVE => undef, undef, 1.0],
	-highlightthickness
		  => [SELF => 'highlightThickness','HighlightThickness',0],
	-troughcolor
		  => [PASSIVE => 'troughColor', 'Background', 'grey55'],
    );
	
    _layoutRequest($c,1);
    $c->OnDestroy(['Destroyed' => $c]);
}

sub anchor {
    my $c = shift;
    my $var = \$c->{Configure}{'-anchor'};
    my $old = $$var;

    if(@_) {
	my $new = shift;
	croak "bad anchor position \"$new\": must be n, s, w or e"
		unless $new =~ /^[news]$/;
	$$var = $new;
    }

    $old;
}

sub _layoutRequest {
    my $c = shift;
    my $why = shift;
    $c->afterIdle(['_arrange',$c]) unless $c->{'layout_pending'};
    $c->{'layout_pending'} |= $why;
}

sub _arrange {
  my $c = shift;
  my $why = $c->{'layout_pending'};
  
  $c->{'layout_pending'} = 0;
  
  my $w = $c->Width;
  my $h = $c->Height;
  my $bw = $c->cget('-borderwidth') + $c->cget('-highlightthickness');
  my $x = abs(int($c->{Configure}{'-padx'})) + $bw;
  my $y = abs(int($c->{Configure}{'-pady'})) + $bw;
  my $value = $c->value;
  my $horz = $c->{Configure}{'-anchor'} =~ /[ew]/i ? 1 : 0;
  my $dir  = $c->{Configure}{'-anchor'} =~ /[ne]/i ? -1 : 1;
  
  
  if($w == 1 && $h == 1) {
	my $bw = $c->cget('-borderwidth');
	$h = $c->pixels($c->cget('-length')) || 40;
	$w = $c->pixels($c->cget('-width'))  || 20;
		
	($w,$h) = ($h,$w) if $horz;
	$c->GeometryRequest($w,$h);
	$c->parent->update;
	$c->update;
	
	$w = $c->Width;
	$h = $c->Height;
  }
  
  $w -= $x*2;
  $h -= $y*2;
  
  my $length = $horz ? $w : $h;
  my $width  = $horz ? $h : $w;
  # at this point we have the length and width of the
  # bar independent of orientation and padding.
  # blocks and gaps are not used.

  # unlike progressbar I need to redraw these each time.
  # actually resizing them might be better...
  my $colors = $c->{Configure}{'-colors'} || ['green','red','grey55'];	
  $c->delete($c->find('all'));	
  $c->createRectangle(0,0,$w+$x*2,$h+$y*2,
					  -fill =>  $c->{Configure}{'-troughcolor'},
					  -width => 0,
					  -outline => undef);
  my $total;
  my $value=$c->cget('-variable');
  my $count_value=scalar(@$value)-1;
  foreach my $val (@$value) {
	$total+=$val>0?$val:0;
  }
  # prevent div by zero and give a nice initial appearance.
  $total=$total?$total:1;
  my $curx=$x;
  my $cury=$y;
  foreach my $index (0..$count_value) {
	my $size=($length*$value->[$index])/$total;
	my $ud=$horz?$width:$size;
	my $lr=$horz?$size:$width;
	$c->{'cover'}->[$index] = 
		$c->createRectangle($curx,$cury,$curx+$lr-1,$cury+$ud-1,
							-fill =>  $colors->[$index],
							-width => 1,
							-outline => 'black');
	$curx+=$horz?$lr:0;
	$cury+=$horz?0:$ud;
  }
}

sub value {
    my $c = shift;
    my $val = $c->cget('-variable');

    if(@_) {
	  $c->configure(-variable=>[@_]);
	  _layoutRequest($c,2);
    }

}

sub Destroyed
{
 my $c = shift;   
 my $var = delete $c->{'-variable'};
 untie $$var if (defined($var) && ref($var))
}

1;

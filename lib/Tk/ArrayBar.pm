package Tk::ArrayBar;
# progressbar doesnt cut it.
# This expects a variable which is an array ref, and
# a matching list of colours. Sortof like stacked progress bars.
# Heavily - ie almost totally - based on the code in ProgressBar.
use Tk;
use Tk::Canvas;
use Tk::ROText;
use Tk::DialogBox;
use Carp;
use strict;

use base qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'ArrayBar';

sub ClassInit {
  my ($class, $mw) = @_;
  
  $class->SUPER::ClassInit($mw);
  
  $mw->bind($class, '<Configure>', [ '_layoutRequest', 1 ]);
}

sub Populate {
    my($c, $args) = @_;
  
    $c->ConfigSpecs(
        -width              => [ PASSIVE => undef, undef, 0           ],
        '-length'           => [ PASSIVE => undef, undef, 0           ],
        -padx               => [ PASSIVE => 'padX', 'Pad', 0          ],
        -pady               => [ PASSIVE => 'padY', 'Pad', 0          ],
        -colors             => [ PASSIVE => undef, undef, undef       ],
        -relief             => [ SELF => 'relief', 'Relief', 'sunken' ],
        -value              => [ METHOD  => undef, undef, undef       ],
        -variable           => [ PASSIVE  => undef, undef, [ 0 ]      ],
        -anchor             => [ METHOD  => 'anchor', 'Anchor', 'w'   ],
        -resolution         => [ PASSIVE => undef, undef, 1.0         ],
        -highlightthickness => [
            SELF => 'highlightThickness', 'HighlightThickness', 0
        ],
        -troughcolor        => [
            PASSIVE => 'troughColor', 'Background', 'grey55'
        ],
    );
  
    _layoutRequest($c, 1);
    $c->OnDestroy([ Destroyed => $c ]);
}

sub anchor {
    my $c = shift;
    my $var = \$c->{Configure}{'-anchor'};
    my $old = $$var;
  
    if (@_) {
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
    $c->afterIdle([ '_arrange', $c ]) unless $c->{layout_pending};
    $c->{layout_pending} |= $why;
}

sub _arrange {
    my $c = shift;
    my $why = $c->{layout_pending};
  
    $c->{layout_pending} = 0;
  
    my $w     = $c->Width;
    my $h     = $c->Height;
    my $bw    = $c->cget('-borderwidth') + $c->cget('-highlightthickness');
    my $x     = abs(int($c->{Configure}{'-padx'})) + $bw;
    my $y     = abs(int($c->{Configure}{'-pady'})) + $bw;
    my $value = $c->cget('-variable');
    my $horz  = $c->{Configure}{'-anchor'} =~ /[ew]/i ? 1 : 0;
    my $dir   = $c->{Configure}{'-anchor'} =~ /[ne]/i ? -1 : 1;
  
    if ($w == 1 && $h == 1) {
	my $bw = $c->cget('-borderwidth');
	$h = $c->pixels($c->cget('-length')) || 40;
	$w = $c->pixels($c->cget('-width'))  || 20;
	
	($w, $h) = ($h, $w) if $horz;
	$c->GeometryRequest($w, $h);
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
    my $colors = $c->{Configure}{'-colors'} || [ 'green', 'red', 'grey55' ];	
    $c->delete($c->find('all'));	
    $c->createRectangle(
        0, 0, $w+$x*2, $h+$y*2,
        -fill    => $c->{Configure}{'-troughcolor'},
        -width   => 0,
        -outline => undef
    );
    my $total;
    my $count_value = scalar(@$value)-1;
    foreach my $val (@$value) {
	$total += $val > 0 ? $val : 0;
    }
    # prevent div by zero and give a nice initial appearance.
    $total = $total ? $total : 1;
    my $curx = $x;
    my $cury = $y;
    foreach my $index (0..$count_value) {
	my $size = ($length*$value->[$index])/$total;
	my $ud = $horz?$width:$size;
	my $lr = $horz?$size:$width;
	$c->{cover}->[$index] = $c->createRectangle(
            $curx, $cury, $curx+$lr-1, $cury+$ud-1,
            -fill    => $colors->[$index],
            -width   => 1,
            -outline => 'black'
        );
	$curx+=$horz?$lr:0;
	$cury+=$horz?0:$ud;
    }
}

sub value {
    my $c = shift;
    my $val = $c->cget('-variable');
  
    if (@_) {
	$c->configure(-variable => [@_]);
	_layoutRequest($c, 2);
    }
}

sub Destroyed {
    my $c = shift;   
    my $var = delete $c->{'-variable'};
    untie $$var if defined($var) && ref($var);
}

1;

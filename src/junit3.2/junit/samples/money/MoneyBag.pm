
=head2 XXXX

A MoneyBag defers exchange rate conversions. For example adding
12 Swiss Francs to 14 US Dollars is represented as a bag
containing the two Monies 12 CHF and 14 USD. Adding another
10 Swiss francs gives a bag with 22 CHF and 14 USD. Due to
the deferred exchange rate conversion we can later value a
MoneyBag with different exchange rates.

A MoneyBag is represented as a list of Monies and provides
different constructors to create a MoneyBag.

=cut

package junit::samples/money::MoneyBag;
use IMoney;
use vars qw(@ISA);
@ISA=qw(IMoney);

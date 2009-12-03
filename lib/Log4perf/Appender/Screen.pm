package Log4perf::Appender::Screen;

=head1 NAME

Log4perf::Appender::Screen - Log to the screen

=cut

use strict;
use warnings;

=head1 METHODS

=over

=item output

=back

=cut

sub output {
    unless ( $_[0]->{'stderr'} ) {
        printf $_[0]->{'format'}, @{$_[1]} or die $!;
    }
    else {
        printf STDERR $_[0]->{'format'}, @{$_[1]} or die $!;
    }
}

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

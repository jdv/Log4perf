package Log4perf::Appender::File;

=head1 NAME

Log4perf::Appender::File - Log to a file

=cut

use strict;
use warnings;

=head1 METHODS

=over

=item output

=back

=cut

sub output {
    unless ( $_[0]->{'handle'} && defined fileno $_[0]->{'handle'} ) {
        open( $_[0]->{'handle'}, '>>', $_[0]->{'filename'} ) or die $!;
    }

    printf { $_[0]->{handle} } $_[0]->{'format'}, @{$_[1]}
      or die $!;
}

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

package Log4perf::Appender::LogDispatchAdapter;

=head1 NAME

Log4perf::Appender::LogDispatchAdapter - Log to any Log::Dispatch appender

=cut

use strict;
use warnings;

=head1 METHODS

=over

=item output

=back

=cut

sub output {
    $_[0]->{'log_dispatch_object'}
      ->log_message( message => sprintf( $_[0]->{'format'}, @{$_[1]} ) );
}

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

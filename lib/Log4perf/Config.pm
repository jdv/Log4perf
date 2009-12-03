package Log4perf::Config;

=head1 NAME

Log4perf::Config - Log4perf Configuration

=cut

use strict;
use warnings;

our $config = {
    levels => {
        all   => 0,
        debug => 10,
        info  => 20,
        warn  => 30,
        error => 40,
        fatal => 50,
        off   => 60,
    },
    stash => {
        compute_on_logger_category => sub { $_[0]->{'category'}; },
        compute_on_logger_level    => sub { $_[0]->{'level'}; },
        compute_on_log_package      => sub { (caller)[0]; },
        compute_on_log_filename     => sub { (caller)[1]; },
        compute_on_log_line         => sub { (caller)[2]; },
        compute_on_log_date         => sub { localtime(); },
        compute_on_log_process_name => sub { $0; },
        compute_on_log_pid          => sub { $$; },
    },
    appenders => {},
    loggers => {},
};

=head1 METHODS

=over

=item config

=back

=cut

sub config { $config; }

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

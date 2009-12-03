package Log4perf::Logger;

=head1 NAME

Log4perf::Logger

=cut

use strict;
use warnings;

=head1 METHODS

=over

=item setup_log_methods

class method

=cut

sub setup_log_methods {
    my ( $proto, $args, ) = @_;

    for my $name ( keys %{ $args->{'levels'} } ) {
        no strict 'refs';
        *{"is_$name"} = sub { $_[0]->{"is_$name"} };
        *{$name} = sub {
            return unless $_[0]->{"is_$name"};

            $_[0]->{'stash'}->{'message'} = ref $_[1] ? $_[1]->() : $_[1];

            for my $name ( @{ $_[0]->{'stash_keys'} } ) {
                my $compute_sub = $_[0]->{'stash'}->{"compute_on_undef_$name"};
                $_[0]->{'stash'}->{$name} = $compute_sub->( $_[0], )
                  if $compute_sub;

                $compute_sub = $_[0]->{'stash'}->{"compute_on_log_$name"};
                $_[0]->{'stash'}->{$name} = $compute_sub->( $_[0], )
                  if $compute_sub;
            }

            my %appender_args;
            for my $logger ( $_[0], @{ $_[0]->{'parent_loggers'} } ) {
                my $stash_is_dirty;
                for my $name ( @{ $_[0]->{'stash_keys'} } ) {
                    my $compute_sub =
                      $_[0]->{'stash'}->{"compute_on_logger_$name"};
                    if ($compute_sub) {
                        $_[0]->{'stash'}->{$name} =
                          $compute_sub->( $_[0], $logger, );
                        $stash_is_dirty++;
                    }
                }
                %appender_args = () if $stash_is_dirty;

                for my $appender ( @{ $logger->{'appenders'} } ) {
                    $appender_args{ $appender->{'name'} } ||=
                      [ @{ $_[0]->{'stash'} }{ @{ $appender->{'args'} } } ];
                    $appender->output( $appender_args{ $appender->{name} } );
                }
                last unless $logger->{'additivity'};
            }
        };
    }
}

=item set_level

=back

=cut

sub set_level {
    die "unknown level: $_[1]" unless defined $_[0]->{'levels'}->{ $_[1] };

    for ( keys %{ $_[0]->{'levels'} } ) {
        $_[0]->{"is_$_"} =
          $_[0]->{'levels'}->{ $_[0]->{'level'} } <= $_[0]->{'levels'}->{$_}
          ? 1
          : 0;
    }
}

1;

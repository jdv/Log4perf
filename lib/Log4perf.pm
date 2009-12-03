package Log4perf;

=head1 NAME

Log4perf - Like Log4perl but faster

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

use 5.008;
use Log4perf::Appender::File;
use Log4perf::Appender::Null;
use Log4perf::Appender::Screen;
use Log4perf::Appender::String;
use Log4perf::Config;
use Log4perf::Logger;
use strict;
use warnings;

=head1 SYNOPSIS

use Log4perf;

Log4perf->easy_setup( 'debug' );

my $log = Log4perf->get_logger( '' );

# conventional
$log->debug( 'foo' ) if $log->is_debug;

# or closure
$log->debug( sub { 'bar' } );

# or fastest
$log->debug( 'baz' ) if $log->{is_debug};

=head1 DESCRIPTION

This distribution has two guiding principles:
 * to support the core features of Log::Log4perl
 * to be as performant as possible

The basic Log::Log4perl functionalities of categories,
levels, formats, appenders, and loggers are provided.

=head1 METHODS

=over

=item setup_appenders

=cut

sub setup_appenders {
    my $appenders = Log4perf::Config->config->{'appenders'};

    for my $name ( keys %{$appenders} ) {
        my $appender = $appenders->{$name};
        if ( $appender->{'type'} =~ /^Log::Dispatch::/ ) {
            eval "use $appender->{ 'type' };";
            die $@ if $@;
            bless( $appender, 'Log4perf::Appender::LogDispatchAdapter' );
            my $new_args = $appender->{'new_args'};
            $appender->{'log_dispatch_object'} = $appender->{'type'}->new(
                min_level => 'debug',
                filename  => $appender->{'filename'},
                ( $new_args ? @{$new_args} : () ),
            );
        }
        else {
            bless( $appender, 'Log4perf::Appender::' . $appender->{'type'} );
        }

        my $format_regex = qr/%([^%{]*?[a-zA-Z])(?:\{([^}]+?)\})?/;
        my @cspecs = $appender->{'format'} =~ /$format_regex/g;
        my @args;
        for ( my $i = 0 ; $i < @cspecs ; $i++ ) {
            if ( $i % 2 && $cspecs[$i] ) {
                push( @args, $cspecs[$i] );
                my $from = $cspecs[ $i - 1 ] . "{$cspecs[ $i ]}";
                $appender->{'format'} =~ s/\Q$from\E/$cspecs[ $i - 1 ]/;
            }
        }
        $appender->{'args'} = \@args;
    }
}

=item setup_loggers

=cut

sub setup_loggers {
    my ( $proto, @loggers, ) = @_;

    my $config = Log4perf::Config->config;

    @loggers = values %{ $config->{'loggers'} } unless @loggers;

    for my $logger (@loggers) {
        bless( $logger, 'Log4perf::Logger' );

        $logger->{'levels'} = $config->{'levels'};

        $logger->{'stash'} = $config->{'stash'};

        $logger->set_level( $logger->{'level'} );

        $logger->{'appenders'} =
          [ map { ref $_ ? $_ : $config->{'appenders'}->{$_}; }
              @{ $logger->{'appenders'} } ];

        $logger->{'parent_loggers'} =
          $proto->get_parent_loggers( $logger->{'category'}, );
    }

    for my $logger_ (@loggers) {
        for my $logger ( $logger_, @{ $logger_->{'parent_loggers'} } ) {
            for my $appender ( @{ $logger->{'appenders'} } ) {
                for ( @{ $appender->{args} } ) {
                    $logger_->{'stash'}->{$_} = undef
                      unless defined $logger_->{'stash'}->{$_};
                }
            }
        }
        $logger_->{'stash_keys'} = [
            grep { not substr( $_, 0, 11, ) eq 'compute_on_'; }
              keys %{ $logger_->{'stash'} }
        ];
    }
}

=item get_parent_loggers

=cut

sub get_parent_loggers {
    my $loggers = Log4perf::Config->config->{'loggers'};

    my @parent_loggers;
    for ( reverse sort grep { $_ ne $_[ 1 ]; } keys %{$loggers} ) {
        my $is_parent =
          ( "$_." eq substr( $_[ 1 ], 0, length($_) + 1 )
              && length $_[ 1 ] > length $_ )
          || $_ eq '';
        push( @parent_loggers, $loggers->{$_}, ) if $is_parent;
    }

    return \@parent_loggers;
}

=item get_logger

=cut

sub get_logger {
    my $category = defined $_[1] ? $_[1] : (caller)[0];
    $category =~ s/::/./g;

    my $loggers = Log4perf::Config->config->{'loggers'};

    return $loggers->{$category} if $loggers->{$category};

    my $parent_loggers = $_[0]->get_parent_loggers( $category, );

    $loggers->{$category} = bless(
        {
            category       => $category,
            level          => $parent_loggers->[0]->{'level'},
            additivity     => 1,
            parent_loggers => $parent_loggers,
        },
        'Log4perf::Logger',
    );
    $_[0]->setup_loggers( $loggers->{$category}, );
    return $loggers->{$category};
}

=item easy_setup

=back

=cut

sub easy_setup {
    my $config = Log4perf::Config->config;
    $config->{appenders}->{screen1} = {
        name   => 'screen1',
        type   => 'Screen',
        format => "%s{date} %s{message}\n",
    };
    my $level = $_[ 1 ] || 'error';
    $config->{loggers}->{''} = {
        level          => $level,
        additivity     => 1,
        appenders      => [qw( screen1 )],
        parent_loggers => [],
        category       => '',
    };
    Log4perf->setup_appenders;
    Log4perf->setup_loggers;
}

Log4perf->setup_appenders;
Log4perf->setup_loggers;
Log4perf::Logger->setup_log_methods(
    { levels => Log4perf::Config->config->{'levels'}, },
);

=head1 AUTHOR

Justin DeVuyst, C<justin@devuyst.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by Justin DeVuyst.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

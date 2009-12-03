use Log4perf;
use strict;
use Test::More tests => 1;
use warnings;

my $appender = Log4perf::Config->config->{ 'appenders' }->{ 'string1' } = {
    name     => 'string1',
    type     => 'String',
    format   => "%s{date} %s{message}\n",
};
Log4perf::Config->config->{ 'loggers' }->{ '' } = {
    level          => 'debug',
    additivity     => 1,
    appenders      => [qw( string1 )],
    parent_loggers => [],
    category       => '',
};
Log4perf->setup_appenders;
Log4perf->setup_loggers;

my $log = Log4perf->get_logger( '' );
$log->debug( 'foo' );
is( $appender->{string}, localtime() . " foo\n" );

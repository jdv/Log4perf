use inc::Module::Install;

all_from 'lib/Log4perf.pm';

recursive_author_tests( 'xt' );

WriteAll;

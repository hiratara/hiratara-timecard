use inc::Module::Install;
name 'Hiratara-Timecard';
all_from 'lib/Hiratara/Timecard.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
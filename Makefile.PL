use inc::Module::Install;
name 'Hiratara-Timecard';
all_from 'lib/Hiratara/Timecard.pm';

requires 'Time::Piece';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

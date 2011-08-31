#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

BEGIN { use_ok('Catalyst::Plugin::StatusMessage'); }

my $msgs = new_ok('Catalyst::Plugin::StatusMessage');

# Hack in a session method to return a hashref
$msgs->meta->make_mutable;
my %session_data;
$msgs->meta->add_method('session', sub { return \%session_data; });
$msgs->meta->make_immutable;

# Set some status and error messages
my $token_01 = $msgs->set_status_msg('Test #01');
my $token_02 = $msgs->set_status_msg('Test #02');
my $token_03 = $msgs->set_error_msg('Test #03');
my $token_04 = $msgs->set_error_msg('Test #04');

# Make sure we get those messages back
ok($msgs->get_status_msg($token_01), 'Test #01');
ok($msgs->get_status_msg($token_02), 'Test #02');
ok($msgs->get_error_msg($token_03), 'Test #03');
ok($msgs->get_error_msg($token_04), 'Test #04');

# Try some failure situations
is($msgs->get_status_msg('NA'), '', 'Lookup bad msg token');
is($msgs->get_error_msg('NA'), '', 'Lookup bad error token');
is($msgs->get_status_msg($token_04), '', 'Lookup error token as msg');
is($msgs->get_error_msg($token_01), '', 'Lookup msg token as error');

done_testing();

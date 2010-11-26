use strict;
use warnings;
use Test::More 'no_plan';
use Net::RiakPB;

my $client = Net::RiakPB->new(
    hostname => '127.0.0.1',
    port => '90000',
);

isa_ok $client, 'Net::RiakPB';

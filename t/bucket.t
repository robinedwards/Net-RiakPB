use strict;
use warnings;
use Test::More 'no_plan';
use Net::RiakPB;
use Data::Dumper;

my ($host,$port) = split ':', $ENV{RIAKPBC};

my $client = Net::RiakPB->new(
    hostname => $host,
    port => $port,
);

isa_ok $client, 'Net::RiakPB';

my $bucket = $client->bucket("TEST_$$\_foo");

isa_ok $bucket, 'Net::RiakPB::Bucket';

ok $bucket->set_properties({
        n_val => 2,
        allow_mult => 1,
    }), 'set properties ok';

my $prop = $bucket->get_properties;

is $prop->{n_val}, 2, 'got property n_val';
is $prop->{allow_mult}, 1,  'got property mult';


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

# fetch throw error
eval { my $bar = $bucket->get('bar') } ;
ok $@ =~ /is empty/, 'obj doesnt exist throws, error';

# delete always succeeds
ok $bucket->delete_object('bar'), 'deleted bar';

# store obje
my $bob = $bucket->new_object('bob', {'name' => 'bob', age => 23 });
isa_ok $bob, 'Net::RiakPB::Object', 'stored obj';

# fetch obj
my $bob2 = $bucket->get('bob');
isa_ok $bob2, 'Net::RiakPB::Object', 'retrieved obj';

# delete obj
ok $bob2->delete, 'deleted bob';
eval{ $bucket->get('bob') };
ok defined $@, 'bob no loneger exists';
ok $bob2->delete, 'deleted bob';


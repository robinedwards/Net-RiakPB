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

ok $client->is_alive, "can ping";

ok ref($client->all_buckets) eq 'ARRAY', "returns array ref";

my $resp = $client->server_info;

ok exists $resp->{version}, 'got version';
ok exists $resp->{node}, 'got node';

ok $client->id('123456'), 'set client_id';
is $client->id, '123456', 'set client_id matches resp';

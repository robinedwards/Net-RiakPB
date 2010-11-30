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

# set properties for bucket
ok $bucket->set_properties({
        n_val => 2,
        allow_mult => 1,
    }), 'set properties ok';

# get properties for bucket
my $prop = $bucket->get_properties;
is $prop->{n_val}, 2, 'got property n_val';
is $prop->{allow_mult}, 1,  'got property mult';

# n_val method
$bucket->n_val(3);
$prop = $bucket->get_properties;
is $prop->{n_val}, 3, 'got property n_val';

for (1..300) {
    $bucket->new_object("bob$_" => {'name' => 'bob', age => 23 });
}

# list keys
is scalar($bucket->get_keys), 300, 'returns 300 keys';

my $count = 0;

$bucket->get_keys({ cb => sub {
            die "no key passed" unless defined shift;
            $count++;    
        }
    });

is $count, 300, 'returns 300 keys in call back mode';

use 5.008;
use MooseX::Declare;

role Net::RiakPB::Quorum {
    requires 'client';
    use MooseX::Types::Moose 'Int';

    for my $q (qw/r w dw/) {
        has $q => (
            is => 'rw',
            isa => Int,
            lazy => 1,
            builder => sub { shift->client->$q },
        );
    }
}

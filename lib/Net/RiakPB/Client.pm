use 5.008;
use MooseX::Declare;

class Net::RiakPB::Client {
    use MooseX::Types::Moose qw/Str Int/;
    use Net::RiakPB::Types 'Socket';
    use IO::Socket::INET;

    has hostname => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

    has port => (
        is => 'ro',
        isa => Int,
        required => 1,
    );

    has timeout => (
        is => 'ro',
        isa => Int,
        default => 200,
    );

    has socket => (
        is => 'rw',
        isa => Socket,
        handles => {
            disconnect => 'close',
        },
        predicate => 'has_socket',
    );

    has r => (
        is => 'ro',
        isa => Int,
        default => 2
    );

    has w => (
        is => 'ro',
        isa => Int,
        default => 2
    );

    has dw => (
        is => 'ro',
        isa => Int,
        default => 2
    );

    has id => (
        is => 'ro',
        isa => Int,
        default => sub { int(rand()*100).$$ }
    );

    method connected {
        return $self->has_socket && $self->socket->connected ? 1 : 0;
    }

    method connect {
        return if $self->has_socket && $self->connected;

        $self->socket(
            IO::Socket::INET->new(
                PeerAddr => $self->hostname,
                PeerPort => $self->port,
                Proto => 'tcp',
                Timeout => $self->timeout,
            )
        );
    }
}

1;

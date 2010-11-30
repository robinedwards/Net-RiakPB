use 5.008;
use MooseX::Declare;

class Net::RiakPB::Message {
    use MooseX::Types::Moose qw/Str HashRef Int/;
    use Net::RiakPB::Types 'Socket';
    use Net::RiakPB::Message::Code qw/
       REQ_CODE EXPECTED_RESP RESP_CLASS RESP_DECODER/;
    use Net::RiakPB::Message::Protocol;
    use Data::Dumper;
    
    has socket => (
        is => 'rw',
        isa => Socket,
        predicate => 'has_socket',
    );

    has message_type => (
        required => 1,
        isa => Str,
        is => 'ro',
        trigger => sub {
            $_[0]->{message_type} = 'Rpb'.$_[1];
        }
    );

    has request_code => (
        required => 1,
        isa => Int, 
        is => 'ro',
        lazy_build => 1,
    );

    has params => (
        isa => HashRef,
        is => 'ro',
    );

    has request => (
        isa => 'Str',
        is => 'ro',
        lazy_build => 1,
    );

    method _build_request_code {
        return REQ_CODE($self->message_type);
    }

    method _build_request {
        return $self->_pack_request(
            $self->request_code,
            $self->encode
        );
    }

    method encode {
        return $self->message_type->can('encode') ?
            $self->message_type->encode($self->params) : '';
    }

    method decode (ClassName $class: Str $type, Str $raw_content) {
        return 'Rpb'.$type->decode($raw_content);
    }

    # inflate to error response class
    method send (CodeRef $cb?) {
        die "No socket? did you forget to ->connect?"
            unless $self->has_socket;

        $self->socket->print($self->request);
        
        my $resp = $self->handle_response;

        return $resp unless ($cb);

        # multiple responses
        $cb->($resp);
        while (!$resp->done) {
            $resp = $self->handle_response;
            $cb->($resp); 
        }

        return 1;
    }

    method handle_response {
        my ($code, $resp) = $self->_unpack_response;

        my $expected_code = EXPECTED_RESP($self->request_code);
        
        if ($expected_code != $code) {
            # TODO throw object
            die "Expecting response type "
                . RESP_CLASS($expected_code)
                . " got " . RESP_CLASS($code);
        }

        return 1 unless RESP_DECODER($code);
        return RESP_DECODER($code)->decode($resp);
    }

    method _pack_request(Int $code, Str $req) {
        my $h = pack('c', $code) . $req;
        use bytes;
        my $len = length $h;
        return pack('N',$len).$h;
    }


    method _unpack_response {
        my ($len, $code, $msg);
        $self->socket->read($len, 4);
        $len = unpack('N', $len);
        $self->socket->read($code, 1);
        $code = unpack('c', $code);
        $self->socket->read($msg, $len -1);
        return ($code, $msg); 
    }
}

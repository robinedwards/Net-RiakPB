use 5.008;
use MooseX::Declare;

class Net::RiakPB {
    use MooseX::MultiMethods;
    use Net::RiakPB::Types Client => { -as => 'Client_T' };
    use Net::RiakPB::Client;
    use Net::RiakPB::Bucket;
    use MIME::Base64 qw/encode_base64 decode_base64/;

    has client => (
        is => 'ro',
        isa => Client_T,
        required => 1,
        handles => [qw/
            connected r w dw 
            hostname port timeout
            /]
    );

    with 'Net::RiakPB::Message::Builder';

    around BUILDARGS (ClassName $class: %params) {
        return {client => Net::RiakPB::Client->new(%params)};
    }

    method bucket (Str $bucket){
        return Net::RiakPB::Bucket->new(
            client => $self->client,
            name => $bucket,
        );
    }

    method all_buckets {
        my $resp = $self->send_message('ListBucketsReq');
        return $resp->buckets;
    }

    method ping {
        return $self->send_message('PingReq');
    }

    method server_info {
        my $resp = $self->send_message('GetServerInfoReq');
        return {node => $resp->node, version => $resp->server_version};
    }

    multi method id (Str $id) {
        return $self->send_message(
            SetClientIdReq => { client_id => pack('N',$id)}
        );
    }

    multi method id {
        my $id = $self->send_message('GetClientIdReq')->client_id;
        return unpack('N', $id);
    }
}

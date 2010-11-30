use 5.008;
use MooseX::Declare;

class Net::RiakPB::Bucket {
    use MooseX::Types::Moose 'Str';
    use MooseX::MultiMethods;
    use Net::RiakPB::Types qw/Client Content/;
    use Net::RiakPB::Object;

    has name => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

    has client => (
        is => 'ro',
        isa => Client,
        required => 1,
        handles => [qw/r w dw/]
    );
    
    with 'Net::RiakPB::Message::Builder';

    method delete_object(Str $key, Int $w?) {
        return $self->send_message(
            DelReq => {
                bucket => $self->name,
                key => $key,
                rw => $w || $self->w,
            }
        );
    }

    method get (Str $key, Int $r?) {
        return Net::RiakPB::Object->new(
            key => $key,
            client => $self->client,
            bucket => $self->name,
        )->load;
    }

    multi method new_object (Str $key, HashRef $data) {
        return Net::RiakPB::Object->new(
            key => $key,
            bucket => $self->name,
            content => { value => $data },
            client => $self->client,
        )->store;
    }

    multi method new_object (Str $key, Content $content) {
        return Net::RiakPB::Object->new(
            key => $key,
            bucket => $self->bucket,
            content => $content,
            client => $self->client,
        )->store;
    }

    method all_keys {

    }

    # TODO type checking on set value structure
    method set_properties (HashRef $prop) {
        return $self->send_message(
            SetBucketReq => {
                bucket => $self->name,
                props => $self->new_message(
                    BucketProps => $prop
                ),
            }
        );
    }

    method get_properties {
        my $resp = $self->send_message(
            GetBucketReq => {
                bucket => $self->name
            }
        );

        return {%{$resp->props}};
    }
}

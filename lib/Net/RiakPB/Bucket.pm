use 5.008;
use MooseX::Declare;

class Net::RiakPB::Bucket {
    use Net::RiakPB::Types 'Client';
    use MooseX::Types::Moose 'Str';
    use Data::Dumper;

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

    method new_object(Str $key, HashRef $obj) {

    }

    method get (Str $key) {

    }

    method all_keys {

    }

    method delete {

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

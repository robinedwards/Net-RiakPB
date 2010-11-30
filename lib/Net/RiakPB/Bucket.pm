use 5.008;
use MooseX::Declare;

class Net::RiakPB::Bucket {
    use MooseX::Types::Moose 'Str';
    use MooseX::MultiMethods;
    use Data::Dumper;
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

    multi method get_keys {
        my $keys = [];

        $self->send_message(
            ListKeysReq => {
                bucket => $self->name,
            },

            sub {
                if (defined $_[0]->keys) {
                    push @$keys, @{$_[0]->keys};  
                } 
            }
        );

        return @$keys;
    }

    multi method get_keys(HashRef $param) {
        my $cb = $param->{cb};

        my $count = 0;

        $self->send_message(
            ListKeysReq => {
                bucket => $self->name,
            },

            sub { 
                if (defined $_[0]->keys) {
                    $cb->($_) for (@{$_[0]->keys});
                }
            }
        );
    }


    # TODO type checking on set value structure
    method set_properties (HashRef $prop) {
        return $self->send_message(
            SetBucketReq => {
                bucket => $self->name,
                props => $prop
            }
        );
    }

    method n_val (Int $n) {
        $self->set_properties({n_val => $n});
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

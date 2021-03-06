use 5.008;
use MooseX::Declare;

class Net::RiakPB::Object::Content {
    use Data::Dumper;
    use Net::RiakPB::Types qw/Link Pair/;
    use MooseX::Types::Moose qw/Str ArrayRef Any Int Ref/;
    use Perl6::Junction 'all';
    use JSON::XS;

    has value => (
        is => 'rw',
        isa => Ref,
    );

    has content_type => (
        is => 'rw',
        isa => Str,
        default => 'application/json',
    );

    has charset => (
        is => 'rw',
        isa => Str,
    );

    has content_encoding => (
        is => 'rw',
        isa => Str,
    );

    has vtag => (
        is => 'rw',
        isa => Str,
    );

    has links => (
        is => 'rw',
        isa => ArrayRef[Link],
        traits => ['Array'],
        handles => {

        }
    );

    has last_mod => (
        is => 'rw',
        isa => Int,
    );

    has last_mod_usecs => (
        is => 'rw',
        isa => Int,
    );

    has usermeta => (
        is => 'rw',
        isa => ArrayRef[Pair],
        handles => {

        }
    );

    # want to keep class immutable
    my @attributes = qw/usermeta last_mod_usecs last_mod 
        links vtag content_encoding charset content_type value/;

    method decode (Object $message) {
        die "no message returned" unless $message->isa('RpbContent');

        for my $attr ( grep { $_ ne all(qw/links usermeta value/) } 
            @attributes ) {
                $self->$attr($message->$attr) if defined $message->$attr;
        }

        $self->${\"decode_$_"}($message->$_) for (qw/value/);

        return $self;
    }

    method decode_links {
        die "todo";
    }

    method decode_usermeta {
        die "todo";
    }

    method decode_value (Str $value){
        if ( $self->content_type eq 'application/json' ) {
            $self->value( decode_json($value));
        }
        else {
            die "Decoding for ".$self->content_type." is not implemented.";
        }
    }

    method encode {
        my $params = { 
            map { $_ => $self->$_ } 
            grep { $_ ne all(qw/links usermeta value/) } @attributes
        };

        $params->{$_} = $self->${\"encode_$_"} for qw/links usermeta value/;

        return $params;
    }

    method encode_value {
        if ( $self->content_type eq 'application/json' ) {
            return encode_json($self->value);
        }
        else {
            die "Encoding for ".$self->content_type." is not implemented.";
        }
    }

    method encode_usermeta {
        return undef;
    }

    method encode_links {
        return undef;
    }
}

1;

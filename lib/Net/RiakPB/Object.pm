use 5.008;
use MooseX::Declare;

class Net::RiakPB::Object {
    use Data::Dumper;
    use Net::RiakPB::Types Client => { -as => 'Client'},
                           Content => { -as => 'Content_T'};
    use Net::RiakPB::Object::Content;
    use MooseX::Types::Moose qw/Str Any/;
    use Try::Tiny;

    has key => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    
    has bucket => (
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

    has vclock => (
        is => 'rw',
        isa => Any,
        predicate => 'has_vclock',
    );

    has content => (
        is => 'rw',
        isa => Content_T,
        coerce => 1,
        predicate => 'has_content'
    );
    
    with 'Net::RiakPB::Message::Builder';

    method load (Int $r?) {
        my $resp = $self->send_message(
            GetReq => {
                bucket => $self->bucket,
                key => $self->key,
                r => $r || $self->r,
            }
        );

        my $content = Net::RiakPB::Object::Content->new;
        
        die "The object '".$self->key. "' in bucket '"
            . $self->bucket . "' is empty!"
            unless defined $resp->content;

        $self->content(
            $content->decode($resp->content)
        );

        return $self;
    }

    method store {
        $self->send_message(PutReq => {
                bucket => $self->bucket,
                key => $self->key,
                content => $self->content->encode,
            }
        );

        return $self;
    }
}

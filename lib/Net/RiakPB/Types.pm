use 5.01;
use MooseX::Declare;

class Net::RiakPB::Types {
    use Data::Dump 'pp';
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose qw/Str HashRef/;
    use MooseX::Types::Structured qw/Tuple Optional Dict/;
    use MooseX::Types -declare => [qw/Socket Client Link Pair Content/];

    class_type Socket, { class => 'IO::Socket::INET' };
    class_type Client, { class => 'Net::RiakPB::Client' };
    class_type Content, { class => 'Net::RiakPB::Object::Content' };

    coerce Content,
        from HashRef,
        via {
            Net::RiakPB::Object::Content->new($_);
        };

    subtype Pair,
        as Tuple[Str, Optional[Str]],
        message { "Not a valid Pair structure: ".pp($_) }; 

    subtype Link,
        as Dict[
            bucket => Optional[Str],
            key => Optional[Str],
            tag => Optional[Str],
        ],
        message { "Not a valid link structure: ".pp($_) }; 
}

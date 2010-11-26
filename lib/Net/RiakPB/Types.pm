use 5.01;
use MooseX::Declare;

class Net::RiakPB::Types {
    use Moose::Util::TypeConstraints;
    use MooseX::Types -declare => [qw/Socket Client/];

    class_type Socket, { class => 'IO::Socket::INET' };
    class_type Client, { class => 'Net::RiakPB::Client' };
}

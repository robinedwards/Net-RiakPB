use 5.008;
use MooseX::Declare;

role Net::RiakPB::Message::Builder {
    use Net::RiakPB::Message;
    use MooseX::MultiMethods;

    requires 'client';

    multi method send_message(Str $type, HashRef $params?) {
        $self->client->connect unless $self->client->connected;

        my $message = Net::RiakPB::Message->new(
            message_type => $type,
            params => $params || {},
        );

        $message->socket($self->client->socket);

        return $message->send;
    }

    multi method send_message(Str $type, HashRef $params, CodeRef $cb) {
        $self->client->connect unless $self->client->connected;

        my $message = Net::RiakPB::Message->new(
            message_type => $type,
            params => $params,
        );

        $message->socket($self->client->socket);

        return $message->send($cb);
    }

}

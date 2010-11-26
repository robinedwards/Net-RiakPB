use 5.008;
use MooseX::Declare;

role Net::RiakPB::Message::Builder {
    use Net::RiakPB::Message;
    requires 'client';

    method send_message(Str $type, HashRef $params?) {
        $self->client->connect unless $self->client->connected;

        my $message = $self->new_message($type, $params);
        $message->socket($self->client->socket);

        return $message->send;
    }

    method new_message(Str $type, HashRef $params?) {
        my $message = Net::RiakPB::Message->new(
            message_type => $type,
            params => $params || {}
        );

        return $message;
    }
}

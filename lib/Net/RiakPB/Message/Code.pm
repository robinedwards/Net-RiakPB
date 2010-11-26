package Net::RiakPB::Message::Code;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw/
    REQ_CODE
    RESP_CLASS
    EXPECTED_RESP
    RESP_DECODER
/;

sub EXPECTED_RESP {
    my $code = shift;
    return {
        1 => 2,
        3 => 4,
        5 => 6,
        7 => 8,
        9 => 10,
        11 => 12,
        13 => 14,
        15 => 16,
        17 => 18,
        19 => 20,
        21 => 22,
        23 => 24,
    }->{$code};
}
sub RESP_CLASS {
    my $code = shift;

    return {
        0 => 'RpbErrorResp',
        2 => 'RpbPingResp',
        4 => 'RpbGetClientIdResp',
        6 => 'RpbSetClientIdResp',
        8 => 'RpbGetServerInfoResp',
        10 => 'RpbGetResp',
        12 => 'RpbPutResp',
        14 => 'RpbDelResp',
        16 => 'RpbListBucketsResp',
        18 => 'RpbListKeysResp',
        20 => 'RpbGetBucketResp',
        22 => 'RpbSetBucketResp',
        24 => 'RpbMapRedResp',
    }->{$code};
}

sub RESP_DECODER {
    my $code = shift;

    return {
        0 => 'RpbErrorResp',
        2 => undef,
        4 => 'RpbGetClientIdResp',
        6 => undef,
        8 => 'RpbGetServerInfoResp',
        10 =>  'RpbGetResp',
        12 =>  'RpbPutResp',
        14 =>  undef,
        16 =>  'RpbListBucketsResp',
        18 =>  'RpbListKeysResp',
        20 =>  'RpbGetBucketResp',
        22 =>  undef,
        24 =>  'RpbMapRedResp'
    }->{$code};
};


sub REQ_CODE {
    my $class = shift;

    return {
        RpbPingReq => 1,
        RpbGetClientIdReq => 3,
        RpbSetClientIdReq => 5,
        RpbGetServerInfoReq => 7,
        RpbGetReq => 9,
        RpbPutReq => 11,
        RpbDelReq => 13,
        RpbListBucketsReq => 15,
        RpbListKeysReq => 17,
        RpbGetBucketReq => 19,
        RpbSetBucketReq => 21,
        RpbMapRedReq => 23,
    }->{$class};
}

1;

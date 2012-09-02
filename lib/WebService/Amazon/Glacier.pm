use strict;
use warnings;
package WebService::Amazon::Glacier;

use MooseX::App qw(Config);
use Net::Amazon::SignatureVersion4;
use YAML::XS;
use LWP::Protocol::https;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request;
use URI::Encode;
use Digest::SHA qw(sha256_hex);
use POSIX qw(strftime);
use JSON;
use 5.010;


# ABSTRACT: Perl module to access Amazon's Glacier  service.
# PODNAME: WebService::Amazon::Glacier

=head1 SYNOPSIS

use WebService::Amazon::Glacier;

=head2 DESCRIPTION

This module interacts with the Amazon Glacier service.

=cut 

option 'Access_Key_Id' => (
    is        => 'rw',
    isa       => 'Str',
    reader    => 'get_Access_Key_ID',
    predicate => 'has_Access_Key_ID',
    );

option 'Secret_Access_Key' => (
    is        => 'rw',
    isa       => 'Str',
    reader    => 'get_Secret_Access_Key',
    predicate => 'has_Secret_Access_Key',
    );

option 'AccountID' => (
    is        => 'rw',
    isa       => 'Str',
    reader    => 'get_AccountID',
    predicate => 'has_AccountID',
    default   => '-',
    );

has 'Net_Amazon_SignatureVersion4' => (
    is     => 'rw',
    isa    => 'Object',
    writer => 'set_Net_Amazon_SignatureVersion4',
    reader => 'get_Net_Amazon_SignatureVersion4',
    );

option 'region' => (
    is      => 'rw',
    isa     => 'Str',
    writer  => 'set_region',
    reader  => 'get_region',
    default => 'us-east-1',
    );

option 'ua' => (
    is     => 'rw',
    isa    => 'Object',
    writer => 'set_ua',
    reader => 'get_ua',
    );


=method BUILD

This is the builder for this class.

=cut
sub BUILD{
    my $self=shift;
    my $awsSign=new Net::Amazon::SignatureVersion4();
    $awsSign->set_Access_Key_ID($self->get_Access_Key_ID());
    $awsSign->set_Secret_Access_Key($self->get_Secret_Access_Key());
    $awsSign->set_service('glacier');
    $awsSign->set_region($self->get_region());
    $self->set_Net_Amazon_SignatureVersion4($awsSign);
    $self->set_ua(LWP::UserAgent->new( agent => 'perl-WebService::Amazon::Glacier'));
}

=method list_vaults

Returns an array of current vaults owned by the current AccountID.

=cut
sub list_vaults{
    my $self=shift;
    
    my $hr=HTTP::Request->new('GET',"https://glacier.".$self->get_region().".amazonaws.com/".$self->get_AccountID()."/vaults", [ 
				  'Host', "glacier.".$self->get_region().".amazonaws.com", 
				  'Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'X-Amz-Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'x-amz-glacier-version', '2012-06-01',
			       ]);
    $hr->protocol('HTTP/1.1');
    $self->get_Net_Amazon_SignatureVersion4()->set_request($hr);
    my $response = $self->get_ua->request($self->get_Net_Amazon_SignatureVersion4()->get_authorized_request());
    my @rv;
    if ($response->is_success) {
	my $vault_list = decode_json($response->decoded_content());
	@rv=@{$vault_list->{'VaultList'}};
    }
    else {
	die $response->status_line.":".$response->decoded_content;
    }
    
    return (@rv);
}

1;

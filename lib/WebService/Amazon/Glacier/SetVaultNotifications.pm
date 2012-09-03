use strict;
package WebService::Amazon::Glacier::SetVaultNotifications;
use MooseX::App::Command;
use 5.010;
use POSIX qw(strftime);
use HTTP::Request;
use JSON;
use TryCatch;
use WebService::Amazon::Glacier::GlacierError;
extends qw(WebService::Amazon::Glacier);

option 'vaultname' => (
    is            => 'rw',
    isa           => 'Str',
    reader        => 'get_vaultname',
    predicate     => 'has_vaultname',
    required      => 1,
    documentation => q[Name of vault to create],
    );

option 'SNSTopic' => (
    is            => 'rw',
    isa           => 'Str',
    reader        => 'get_SNSTopic',
    predicate     => 'has_SNSTopic',
    required      => 1,
    documentation => q[The Amazon SNS topic ARN.],
    );

option 'ArchiveRetrievalCompleted' => (
    is            => 'rw',
    isa           => 'Bool',
    reader        => 'get_ArchiveRetrievalCompleted',
    predicate     => 'has_ArchiveRetrievalCompleted',
    documentation => q[True if you wish to receive notifications when a job that was initiated for an archive retrieval is completed.],
    default       => 0,
    );

option 'InventoryRetrievalCompleted' => (
    is            => 'rw',
    isa           => 'Bool',
    reader        => 'get_InventoryRetrievalCompleted',
    predicate     => 'has_InventoryRetrievalCompleted',
    documentation => q[True if you wish to receive notifications when a job that was initiated for an inventory retrieval is completed.],
    default       => 0,
    );

sub run {
    my ($self)=@_;
    
    try{
	$self->_set_vault_notifications();
    }catch (WebService::Amazon::Glacier::GlacierError $e){
	die $e->error_message;
    }
    return 0;
}

=method _set_vault_notifications

Sets notifications for a vault.

=cut
sub _set_vault_notifications{
    my $self=shift;
    
    die WebService::Amazon::Glacier::GlacierError->new( error_code => "999",
							error_message => "Must set One of InventoryRetrievalCompleted or ArchiveRetrievalCompleted",
	) unless ( $self->get_ArchiveRetrievalCompleted() | $self->get_InventoryRetrievalCompleted() );
    
    my $request={
	'SNSTopic' => $self->get_SNSTopic(),
	'Events' => [],
    };
    if ($self->get_ArchiveRetrievalCompleted()){
	push @{$request->{'Events'}}, 'ArchiveRetrievalCompleted';
    }

    if ($self->get_InventoryRetrievalCompleted()){
	push @{$request->{'Events'}}, 'InventoryRetrievalCompleted';
    }

    say(encode_json($request));
    
    my $hr=HTTP::Request->new('PUT',"https://glacier.".$self->get_region().".amazonaws.com/".$self->get_AccountID()."/vaults/".$self->get_vaultname()."/notification-configuration", [ 
				  'Host', "glacier.".$self->get_region().".amazonaws.com", 
				  'Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'X-Amz-Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'x-amz-glacier-version', '2012-06-01',
			       ]);
    $hr->content(encode_json($request));

    my $response=$self->_submit_request($hr);

    if ($response->is_success) {
	return;
    } else {
	die WebService::Amazon::Glacier::GlacierError->new( error_code => $response->code(),
							    error_message => $response->as_string(),
	    );

    }
    return;
}

1;
=begin Pod::Coverage

run

=end Pod::Coverage



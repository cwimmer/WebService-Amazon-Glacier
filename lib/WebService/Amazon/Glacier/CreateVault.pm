use strict;
package WebService::Amazon::Glacier::CreateVault;
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

sub run {
    my ($self)=@_;
    
    use Data::Dumper;
#    say(Data::Dumper->Dump([@_]));
    try{
	$self->_create_vault();
    }catch (WebService::Amazon::Glacier::GlacierError $e){
	die $e->error_message;
    }
    return 0;
}

=method _create_vault

Requires vaultname to be set.  Creates the vault.  Throws an exception
if it can't be created for any reason.

=cut
sub _create_vault{
    my $self=shift;
    
    my $hr=HTTP::Request->new('PUT',"https://glacier.".$self->get_region().".amazonaws.com/".$self->get_AccountID()."/vaults/".$self->get_vaultname(), [ 
				  'Host', "glacier.".$self->get_region().".amazonaws.com", 
				  'Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'X-Amz-Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'x-amz-glacier-version', '2012-06-01',
			       ]);

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



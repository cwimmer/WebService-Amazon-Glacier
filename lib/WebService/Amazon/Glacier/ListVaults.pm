use strict;
package WebService::Amazon::Glacier::ListVaults;
use MooseX::App::Command;
use 5.010;
use POSIX qw(strftime);
use HTTP::Request;
use JSON;
use TryCatch;
use WebService::Amazon::Glacier::GlacierError;
extends qw(WebService::Amazon::Glacier);


sub run {
    my ($self)=@_;
    try{
	foreach my $vault ($self->_list_vaults()){
	    say($vault->{'VaultName'});
	}
    }catch (WebService::Amazon::Glacier::GlacierError $e){
	die $e->error_message;
    }
    return 0;
}


=method _list_vaults

Returns an array of current vaults owned by the current AccountID.

=cut
sub _list_vaults{
    my $self=shift;
    
    my $hr=HTTP::Request->new('GET',"https://glacier.".$self->get_region().".amazonaws.com/".$self->get_AccountID()."/vaults", [ 
				  'Host', "glacier.".$self->get_region().".amazonaws.com", 
				  'Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'X-Amz-Date', strftime("%Y%m%dT%H%M%SZ",gmtime(time())) , 
				  'x-amz-glacier-version', '2012-06-01',
			       ]);
    my $response=$self->_submit_request($hr);
    my @rv;
    if ($response->is_success) {
	my $vault_list = decode_json($response->decoded_content());
	@rv=@{$vault_list->{'VaultList'}};
    }
    else {
	die  WebService::Amazon::Glacier::GlacierError->new( error_code => $response->code(),
							     error_message => $response->as_string(),
	    );
    }
    
    return (@rv);
}
1;
=begin Pod::Coverage

run

=end Pod::Coverage



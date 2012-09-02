use strict;
package WebService::Amazon::Glacier::ListVaults;
use MooseX::App::Command;
use 5.010;
extends qw(WebService::Amazon::Glacier);

=method run

usage:
    glacier list_vaults [long options...]
    glacier help
    glacier list_vaults --help

options:
    --Access_Key_Id      
    --AccountID          [Default:"-"]
    --Secret_Access_Key  
    --config             Path to command config file
    --help --usage -?    Prints this usage information. [Flag]
    --region             [Default:"us-east-1"]
    --ua                 



=cut
sub run {
    my ($self)=@_;
    foreach my $vault ($self->list_vaults()){
	say($vault->{'VaultName'});
    }
    return 0;
}
1;

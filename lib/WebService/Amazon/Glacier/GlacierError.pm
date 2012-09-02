use strict;
package WebService::Amazon::Glacier::GlacierError;
use Moose;
use 5.010;

has 'error_code' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
    );

has 'error_message' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    );

sub BUILD{

}

1;
=begin Pod::Coverage

BUILD

=end Pod::Coverage



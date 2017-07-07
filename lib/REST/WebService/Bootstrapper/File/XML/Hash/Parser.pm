package REST::WebService::Bootstrapper::File::XML::Hash::Parser;

use Moose;
use Data::Dumper;
use File::Slurp;
use XML::Hash;

extends 'REST::WebService::Bootstrapper::File::XML::Parser';

use constant TRUE  => 1;
use constant FALSE => 0;

## Singleton support
my $instance;


sub getInstance {

    if (!defined($instance)){

        $instance = new REST::WebService::Bootstrapper::File::XML::Hash::Parser(@_);

        if (!defined($instance)){

            confess "Could not instantiate REST::WebService::Bootstrapper::File::XML::Hash::Parser";
        }
    }
    return $instance;
}

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _parse_file {

    my $self = shift;

    $self->{_logger}->logconfess("NOT YET IMPLEMENTED");    
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 REST::WebService::Bootstrapper::File::XML::Parser
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use REST::WebService::Bootstrapper::File::XML::Parser;
 my $manager = REST::WebService::Bootstrapper::File::XML::Parser::getInstance(
  infile => $infile
 );
 $manager->getRecordList();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut
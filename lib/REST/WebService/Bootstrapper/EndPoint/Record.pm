package REST::WebService::Bootstrapper::EndPoint::Record;

use Moose;
use Log::Log4perl;

use constant TRUE  => 1;
use constant FALSE => 0;

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setName',
    reader   => 'getName',
    required => FALSE
    );

has 'url' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setURL',
    reader   => 'getURL',
    required => FALSE
    );

has 'desc' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDesc',
    reader   => 'getDesc',
    required => FALSE
    );

has 'method' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setMethod',
    reader   => 'getMethod',
    required => FALSE
    );

has 'type' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setType',
    reader   => 'getType',
    required => FALSE
    );

has 'sql' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSQL',
    reader   => 'getSQL',
    required => FALSE
    );

has 'route_parameters_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setRouteParametersList',
    reader   => 'getRouteParametersList',
    required => FALSE
    );

has 'body_parameters_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setBodyParametersList',
    reader   => 'getBodyParametersList',
    required => FALSE
    );

has 'table_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setTableList',
    reader   => 'getTableList',
    required => FALSE
    );

has 'label' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setLabel',
    reader   => 'getLabel',
    required => FALSE
    );

has 'label_desc' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setLabelDesc',
    reader   => 'getLabelDesc',
    required => FALSE
    );

has 'expiry' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setExpiry',
    reader   => 'getExpiry',
    required => FALSE
    );

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _initLogger {

    my $self = shift;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);
    if (!defined($logger)){
        confess "logger was not defined";
    }

    $self->{_logger} = $logger;
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 REST::WebService::Bootstrapper::EndPoint::Record

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use REST::WebService::Bootstrapper::EndPoint::Record;
 my $record = new REST::WebService::Bootstrapper::EndPoint::Record(
  name   => $name,
  url    => $url,
  desc   => $desc,
  method => 'GET',
  sql    => $sql
 );

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut
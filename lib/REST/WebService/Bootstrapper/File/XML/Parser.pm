package REST::WebService::Bootstrapper::File::XML::Parser;

use Moose;
use Data::Dumper;
use File::Slurp;

use REST::WebService::Bootstrapper::EndPoint::Record;

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_USERNAME => getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

## Singleton support
my $instance;

has 'test_mode' => (
    is       => 'rw',
    isa      => 'Bool',
    writer   => 'setTestMode',
    reader   => 'getTestMode',
    required => FALSE,
    default  => DEFAULT_TEST_MODE
    );

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    writer   => 'setVerbose',
    reader   => 'getVerbose',
    required => FALSE,
    default  => DEFAULT_VERBOSE
    );

has 'config_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setConfigfile',
    reader   => 'getConfigfile',
    required => FALSE,
    );

has 'outdir' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOutdir',
    reader   => 'getOutdir',
    required => FALSE,
    default  => DEFAULT_OUTDIR
    );

has 'infile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setInfile',
    reader   => 'getInfile',
    required => FALSE
    );

has 'namespace' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setNamespace',
    reader   => 'getNamespace',
    required => FALSE
    );

sub getInstance {

    if (!defined($instance)){

        $instance = new REST::WebService::Bootstrapper::File::XML::Parser(@_);

        if (!defined($instance)){

            confess "Could not instantiate REST::WebService::Bootstrapper::File::XML::Parser";
        }
    }
    return $instance;
}

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

sub getRecordList {

    my $self = shift;
    
    if (! exists $self->{_endpoint_record_list}){
        $self->_parse_file(@_);
    }

    return $self->{_endpoint_record_list};
}

sub _create_endpoint_record {

    my $self = shift;
    my ($name, $url, $desc, $method, $type, $sql, $route_parameters_list, $body_parameters_list, $table_list) = @_;

    my $record = new REST::WebService::Bootstrapper::EndPoint::Record(
        name   => $name,
        url    => $url,
        desc   => $desc,
        method => $method,
        type   => $type
        );

    if (!defined($record)){
        $self->{_logger}->logconfess("Could not instantiate REST::WebService::Bootstrapper::EndPoint::Record");
    }

    if (defined($sql)){
        $record->setSQL($sql);
    }
    
    if (defined($route_parameters_list)){
        $record->setRouteParametersList($route_parameters_list)
    }

    if (defined($body_parameters_list)){
        $record->setBodyParametersList($body_parameters_list);
    }

    if (defined($table_list)){
        $record->setTableList($table_list);
    }
    
    push(@{$self->{_endpoint_record_list}}, $record);
}

sub _checkInfileStatus {

    my $self = shift;
    my ($infile) = @_;

    if (!defined($infile)){
        $self->{_logger}->logconfess("infile was not defined");
    }

    my $errorCtr = 0 ;

    if (!-e $infile){
        $self->{_logger}->fatal("input file '$infile' does not exist");
        $errorCtr++;
    }
    else {
        if (!-f $infile){
            $self->{_logger}->fatal("'$infile' is not a regular file");
            $errorCtr++;
        }
        
        if (!-r $infile){
            $self->{_logger}->fatal("input file '$infile' does not have read permissions");
            $errorCtr++;
        }
        
        if (!-s $infile){
            $self->{_logger}->fatal("input file '$infile' does not have any content");
            $errorCtr++;
        }
    }

    if ($errorCtr > 0){
        $self->{_logger}->logconfess("Encountered issues with input file '$infile'");
    }
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
 my $manager = REST::WebService::Bootstrapper::File::XML::Parser::getInstance();
 $manager->runBenchmarkTests($infile);

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut

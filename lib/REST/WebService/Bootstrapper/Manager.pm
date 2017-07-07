package REST::WebService::Bootstrapper::Manager;

use Moose;
use Cwd;

use REST::WebService::Bootstrapper::Config::Manager;
use REST::WebService::Bootstrapper::File::XML::Twig::Parser;
use REST::WebService::Bootstrapper::Generator;

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_CONFIG_FILE => "$FindBin::Bin/../conf/bootstrapper.ini";

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_USERNAME => getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

use constant DEFAULT_INDIR => File::Spec->rel2abs(cwd());

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

has 'config_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setConfigFile',
    reader   => 'getConfigFile',
    required => FALSE,
    default  => DEFAULT_CONFIG_FILE
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

has 'indir' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setIndir',
    reader   => 'getIndir',
    required => FALSE,
    default  => DEFAULT_INDIR
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

        $instance = new REST::WebService::Bootstrapper::Manager(@_);

        if (!defined($instance)){

            confess "Could not instantiate REST::WebService::Bootstrapper::Manager";
        }
    }
    return $instance;
}

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->_initParser(@_);

    $self->_initGenerator(@_);

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

sub _initConfigManager {

    my $self = shift;

    my $manager = REST::WebService::Bootstrapper::Config::Manager::getInstance(@_);
    if (!defined($manager)){
        $self->{_logger}->logconfess("Could not instantiate REST::WebService::Bootstrapper::Config::Manager");
    }

    $self->{_config_manager} = $manager;
}

sub _initParser {

    my $self = shift;

    my $parser = REST::WebService::Bootstrapper::File::XML::Twig::Parser::getInstance(@_);
    if (!defined($parser)){
        $self->{_logger}->logconfess("Could not instantiate REST::WebService::Bootstrapper::File::XML::Twig::Parser");
    }

    $self->{_parser} = $parser;
}

sub _initGenerator {

    my $self = shift;

    my $generator = REST::WebService::Bootstrapper::Generator::getInstance(@_);
    if (!defined($generator)){
        $self->{_logger}->logconfess("Could not instantiate REST::WebService::Bootstrapper::Generator");
    }

    $self->{_generator} = $generator;
}


sub run {

    my $self = shift;
    my ($infile) = @_;

    if (!defined($infile)) {
        $infile = $self->getInfile();
        if (!defined($infile)){
            $self->{_logger}->logconfess("infile was not defined");
        }
    }

    $self->{_parser}->setInfile($infile);

    my $record_list = $self->{_parser}->getRecordList();
    if (!defined($record_list)){
        $self->{_logger}->logconfess("record_list was not defined");
    }

    $self->{_generator}->generate($record_list);
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 REST::WebService::Bootstrapper::Manager
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use REST::WebService::Bootstrapper::Manager;
 my $manager = REST::WebService::Bootstrapper::Manager::getInstance(
  outdir => $outdir,
  infile => $infile,
  config_file => $config_file
 );

 $manager->run();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut

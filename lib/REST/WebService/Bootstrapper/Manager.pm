package REST::WebService::Bootstrapper::Manager;

use Moose;
use Cwd;

use REST::WebService::Bootstrapper::Config::Manager;
use REST::WebService::Bootstrapper::File::XML::Twig::Parser;
use REST::WebService::Bootstrapper::Generator;

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_DATABASE => 'bdmprd2';

use constant DEFAULT_USE_DATABASE_PROXY_ACCOUNT => FALSE;

use constant DEFAULT_ORACLE_HOME => '/apps/oracle/product/client/11.2.0/';

use constant DEFAULT_DATABASE_ACCOUNT_TYPE => 'publisher';

## This is the application-specific configuration file
## that is used by the established RESTful web service at
## run time AND NOT the configuration file used by the 
## REST-web-service-bootstrap-utils system.
use constant DEFAULT_APP_CONFIG_INI_FILE   => 'app_config.ini';

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

has 'author' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAuthor',
    reader   => 'getAuthor',
    required => FALSE
    );

has 'copyright' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setCopyright',
    reader   => 'getCopyright',
    required => FALSE
    );

has 'database' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDatabase',
    reader   => 'getDatabase',
    required => FALSE,
    default  => DEFAULT_DATABASE
    );

has 'use_database_proxy_account' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setUseDatabaseProxyAccount',
    reader   => 'getUseDatabaseProxyAccount',
    required => FALSE,
    default  => DEFAULT_USE_DATABASE_PROXY_ACCOUNT
    );

has 'oracle_home' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOracleHome',
    reader   => 'getOracleHome',
    required => FALSE,
    default  => DEFAULT_ORACLE_HOME
    );

has 'database_account_type' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDatabaseAccountType',
    reader   => 'getDatabaseAccountType',
    required => FALSE,
    default  => DEFAULT_DATABASE_ACCOUNT_TYPE
    );

has 'app_config_ini_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAppConfigIniFile',
    reader   => 'getAppConfigIniFile',
    required => FALSE,
    default  => DEFAULT_APP_CONFIG_INI_FILE
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

    $self->_setAdditionalParameters();

    $self->{_generator}->generate($record_list);
}

sub _setAdditionalParameters {

    my $self = shift;

    my $database = $self->getDatabase();
    if (defined($database)){
        $self->{_generator}->setDatabase($database);
    }

    my $use_database_proxy_account = $self->getUseDatabaseProxyAccount();
    if (defined($use_database_proxy_account)){
        $self->{_generator}->setUseDatabaseProxyAccount($use_database_proxy_account);
    }

    my $oracle_home = $self->getOracleHome();
    if (defined($oracle_home)){
        $self->{_generator}->setOracleHome($oracle_home);
    }

    my $database_account_type = $self->getDatabaseAccountType();
    if (defined($database_account_type)){
        $self->{_generator}->setDatabaseAccountType($database_account_type);
    }

    my $app_config_ini_file = $self->getAppConfigIniFile();
    if (defined($app_config_ini_file)){
        $self->{_generator}->setAppConfigIniFile($app_config_ini_file);
    }
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

package REST::WebService::Bootstrapper::Generator;

use Moose;
use Try::Tiny;
use Cwd;
use Data::Dumper;
use File::Path;
use FindBin;
use Term::ANSIColor;
use FindBin;
use Template;


use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_USERNAME => getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

my $modulate_template_file_list = [
    'template/namespace_Logger_tmpl.tt',
    'template/namespace_Config_Manager_tmpl.tt',
    'template/namespace_Config_File_INI_Parser_tmpl.tt',
    'template/namespace_DBUtil_Factory_tmpl.tt',
    'template/namespace_Manager_tmpl.tt',
    'template/namespace_App_tmpl.tt',
    'template/namespace_DBUtil_tmpl.tt',
    'template/namespace_MongoDB_DBUtil_tmpl.tt',
    'template/namespace_MySQL_DBUtil_tmpl.tt',
    'template/namespace_Postgresql_DBUtil_tmpl.tt',
    'template/namespace_Oracle_DBUtil_tmpl.tt'
];


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

has 'endpoint_record_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setEndPointRecordList',
    reader   => 'getEndPointRecordList',
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

        $instance = new REST::WebService::Bootstrapper::Generator(@_);

        if (!defined($instance)){

            confess "Could not instantiate REST::WebService::Bootstrapper::Generator";
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

sub generate {

    my $self = shift;
    my ($record_list) = @_;

    if (!defined($record_list)){

        $record_list = $self->getEndPointRecordList();

        if (!defined($record_list)){

            $self->{_logger}->logconfess("end-point record_list was not defined");
        }
    }

#    $self->_generate_app_module($record_list);

 #   $self->_generate_dbutil_module($record_list);

    $self->_generate_modules();
}

sub _generate_modules {

    my $self = shift;
    
    my $namespace = $self->getNamespace();
    if (!defined($namespace)){
        $self->{_logger}->logconfess("namespace was not defined");
    }

    my $outdir = $self->getOutdir();
    if (!defined($outdir)){
        $self->{_logger}->logconfess("outdir was not defined");
    }

    my $template_file_ctr = 0;

    foreach my $template_file (@{$modulate_template_file_list}){

        $template_file_ctr++;

        if (! $self->_checkTemplateFileStatus($template_file)){
            $self->{_logger}->logconfess("Encountered some problem with template file '$template_file'");
        }

        ## Example: template/namespace_Postgresql_DBUtil_tmpl.tt

        if ($template_file =~ m|template/namespace_(\S+)_tmpl\.tt|){

            my $path = $1; ## e.g. Postgresql_DBUtil
         
            my $partial_namespace = $path;
         
            $partial_namespace =~ s|_|::|g;

            my $full_namespace = $namespace . '::' . $partial_namespace;

            my $outfile = $outdir . '/lib/' . $full_namespace;

            $outfile =~ s|_|/|g;
            
            $outfile =~ s|::|/|g;

            $outfile .= '.pm';

            my $dirname = File::Basename::dirname($outfile);

            if (!-e $dirname){

                 mkpath($dirname) || $self->{_logger}->logconfess("Could not create directory '$dirname' : $!");

                 $self->{_logger}->info("Created directory '$dirname'");
            }

            my $final_lookup = {
                namespace => $full_namespace,
            };
            
            my $tt = new Template({ABSOLUTE => 1});
            if (!defined($tt)){
                $self->{_logger}->logconfess("Could not instantiate TT");
            }

            $tt->process($template_file, $final_lookup, $outfile) || $self->{_logger}->logconfess("Encountered the following Template::process error:" . $tt->error());

            $self->{_logger}->info("Created file '$outfile' using template file '$template_file'");

            print "Wrote '$outfile'\n";
        }
        else {
            $self->{_logger}->logconfess("Encountered unexpected template file name '$template_file'");
        }
    }

    $self->{_logger}->info("Processed '$template_file_ctr' template files");
}


sub _backup_file {

    my $self = shift;
    my ($file) = @_;

    my $bakfile = $file . '.bak';

    move($file, $bakfile) || $self->{_logger}->logconfess("Could not move '$file' to '$bakfile' : $!");

    $self->{_logger}->info("Backed-up '$file' to '$bakfile'");
}


sub _checkTemplateFileStatus {

    my $self = shift;
    my ($file) = @_;

    if (!defined($file)){
        $self->{_logger}->logconfess("file was not defined");
    }

    my $errorCtr = 0 ;

    if (!-e $file){
        $self->{_logger}->fatal("input template file '$file' does not exist");
        $errorCtr++;
    }
    else {
        
        if (!-f $file){
            $self->{_logger}->fatal("'$file' is not a regular file");
            $errorCtr++;
        }
        
        if (!-r $file){
            $self->{_logger}->fatal("input template file '$file' does not have read permissions");
            $errorCtr++;
        }
        
        if (!-s $file){
            $self->{_logger}->fatal("input template file '$file' does not have any content");
            $errorCtr++;
        }
    }
    
    if ($errorCtr > 0){
        $self->{_logger}->fatal("Encountered issues with input template file '$file'");
        return FALSE;
    }

    return TRUE;
}

no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 REST::WebService::Bootstrapper::Generator
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use REST::WebService::Bootstrapper::Generator;
 my $generator = REST::WebService::Bootstrapper::Generator::getInstance(
  namespace            => $namespace,
  outdir               => $outdir,
  endpoint_record_list => $record_list
 );
 $manager->generate();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut

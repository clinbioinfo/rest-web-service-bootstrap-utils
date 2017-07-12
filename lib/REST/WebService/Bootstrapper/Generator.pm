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
use File::Slurp;

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_DESCRIPTION => 'N/A';

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_USERNAME => getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

use constant DEFAULT_APP_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/app_method_perl_tmpl.tt";

use constant DEFAULT_APP_ROUTE_PARAMETER_TEMPLATE_FILE => "$FindBin::Bin/../template/app_route_parameter_tmpl.tt";

use constant DEFAULT_APP_BODY_PARAMETER_TEMPLATE_FILE => "$FindBin::Bin/../template/app_body_parameter_tmpl.tt";

use constant DEFAULT_DBUTIL_ARGUMENT_TEMPLATE_FILE => "$FindBin::Bin/../template/dbutil_argument_tmpl.tt";

use constant DEFAULT_MANAGER_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/manager_method_perl_tmpl.tt";

use constant DEFAULT_SQLITE_DBUTIL_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/sqlite_dbutil_method_perl_tmpl.tt";

use constant DEFAULT_MONGODB_DBUTIL_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/mongodb_dbutil_method_perl_tmpl.tt";

use constant DEFAULT_ORACLE_DBUTIL_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/oracle_dbutil_method_perl_tmpl.tt";

use constant DEFAULT_POSTGRESQL_DBUTIL_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/postgresql_dbutil_method_perl_tmpl.tt";

use constant DEFAULT_MYSQL_METHOD_TEMPLATE_FILE => "$FindBin::Bin/../template/mysql_dbutil_method_perl_tmpl.tt";


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

has 'app_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAppMethodTemplateFile',
    reader   => 'getAppMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_APP_METHOD_TEMPLATE_FILE
    );

has 'app_route_parameter_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAppRouteParameterTemplateFile',
    reader   => 'getAppRouteParameterTemplateFile',
    required => FALSE,
    default  => DEFAULT_APP_ROUTE_PARAMETER_TEMPLATE_FILE
    );

has 'app_body_parameter_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAppBodyParameterTemplateFile',
    reader   => 'getAppBodyParameterTemplateFile',
    required => FALSE,
    default  => DEFAULT_APP_BODY_PARAMETER_TEMPLATE_FILE
    );

has 'manager_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setManagerMethodTemplateFile',
    reader   => 'getManagerMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_MANAGER_METHOD_TEMPLATE_FILE
    );

has 'mongodb_dbutil_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setMongoDBDBUtilMethodTemplateFile',
    reader   => 'getMongoDBDBUtilMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_MONGODB_DBUTIL_METHOD_TEMPLATE_FILE
    );

has 'sqlite_dbutil_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSQLiteDBUtilMethodTemplateFile',
    reader   => 'getSQLiteDBUtilMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_SQLITE_DBUTIL_METHOD_TEMPLATE_FILE
    );

has 'oracle_dbutil_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOracleDBUtilMethodTemplateFile',
    reader   => 'getOracleDBUtilMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_ORACLE_DBUTIL_METHOD_TEMPLATE_FILE
    );

has 'postgresql_dbutil_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setPostgresqlDBUtilMethodTemplateFile',
    reader   => 'getPostgresqlDBUtilMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_POSTGRESQL_DBUTIL_METHOD_TEMPLATE_FILE
    );

has 'mysql_dbutil_method_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setMySQLDBUtilMethodTemplateFile',
    reader   => 'getMySQLDBUtilMethodTemplateFile',
    required => FALSE,
    default  => DEFAULT_MYSQL_METHOD_TEMPLATE_FILE
    );

has 'dbutil_type' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDBUtilType',
    reader   => 'getDBUtilType',
    required => FALSE
    );

has 'dbutil_argument_template_file' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDBUtilArgumentTemplateFile',
    reader   => 'getDBUtilArgumentTemplateFile',
    required => FALSE,
    default  => DEFAULT_DBUTIL_ARGUMENT_TEMPLATE_FILE
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

    $self->_generate_methods($record_list);

    $self->_generate_modules();
}

sub _generate_methods {

    my $self = shift;
    my ($record_list) = @_;

    $self->{_app_method_content_list} = [];

    $self->{_manager_method_content_list} = [];

    my $default_description = DEFAULT_DESCRIPTION;

    foreach my $record (@{$record_list}){

        my $url = $record->getURL();
        if (!defined($url)){
            $self->{_logger}->logconfess("url was not defined for Record : " . Dumper $record);
        }

        my $type = $record->getType();
        if (!defined($type)){
            $self->{_logger}->logconfess("type was not defined for Record : " . Dumper $record);
        }

        my $desc = $record->getDesc();
        if (!defined($desc)){
            $desc = $default_description;
            $self->{_logger}->warn("desc was not defined and therefore was set to default '$desc'");
        }

        my $name = $record->getName();
        if (!defined($name)){
            $self->{_logger}->logconfess("name was not defined for Record : " . Dumper $record);
        }

        my $method_name = lc($name);

        $method_name =~ s|\s+|_|g;

        $method_name =~ s|\-|_|g;

        my $sql = $record->getSQL();
        if (!defined($sql)){
            $self->{_logger}->logconfess("sql was not defined for Record : " . Dumper $sql);
        }


        my $route_parameters_list = $record->getRouteParametersList();

        my $body_parameters_list = $record->getBodyParametersList();

        $self->_get_app_method_content($method_name, $url, $desc, $route_parameters_list, $body_parameters_list);

        $self->_get_manager_method_content($method_name, $url, $desc, $type);

        $self->_set_dbutil_type($type);

        $self->_get_dbutil_method_content($method_name, $url, $sql, $desc, $type, $route_parameters_list, $body_parameters_list);
    }
}

sub _set_dbutil_type {

    my $self = shift;
    my ($type) = @_;

    $type = lc($type);

    my $current_type = $self->getDBUtilType();
    if (!defined($current_type)){
        $self->setDBUtilType($type);
    }
    else {
        if ($current_type ne $type){
            $self->{_logger}->logconfess("current_type '$current_type' does not match type '$type'");
        }
    }
}

sub _get_app_method_content {

    my $self = shift;
    my ($method_name, $url, $desc, $route_parameters_list, $body_parameters_list) = @_;
    
    my $template_file = $self->getAppMethodTemplateFile();
    if (!defined($template_file)){
        $self->{_logger}->logconfess("template_file was not defined");
    }

    my $route_parameters_list_content = $self->_get_route_parameters_list_content($route_parameters_list);

    my $body_parameters_list_content = $self->_get_body_parameters_list_content($body_parameters_list);

    my $argument_list_content = $self->_get_argument_list_content($route_parameters_list, $body_parameters_list);

    my $lookup = {
        url => $url,
        desc => $desc,
        method_name => $method_name,
        route_parameters_list_content => $route_parameters_list_content,
        body_parameters_list_content => $body_parameters_list_content,
        argument_list_content => $argument_list_content
    };

    my $content = $self->_generate_content_from_template($template_file, $lookup);

    push(@{$self->{_app_method_content_list}}, $content);
}

sub _get_route_parameters_list_content {

    my $self = shift;
    my ($route_parameters_list) = @_;

    my $content_list = [];

    foreach my $param (@{$route_parameters_list}){

        my $template_file = $self->getAppRouteParameterTemplateFile();
        if (!defined($template_file)){
            $self->{_logger}->logconfess("template_file was not defined");
        }

        my $lookup = { param => $param};

        my $content = $self->_generate_content_from_template($template_file, $lookup);

        push(@{$content_list}, $content);
    }

    my $content = join("\n\n", @{$content_list});

    return $content;
}

sub _get_body_parameters_list_content {

    my $self = shift;
    my ($body_parameters_list) = @_;

    my $content_list = [];

    foreach my $param (@{$body_parameters_list}){

        my $template_file = $self->getAppBodyParameterTemplateFile();
        if (!defined($template_file)){
            $self->{_logger}->logconfess("template_file was not defined");
        }

        my $lookup = { param => $param};

        my $content = $self->_generate_content_from_template($template_file, $lookup);

        push(@{$content_list}, $content);
    }

    my $content = join("\n\n", @{$content_list});
    
    return $content;
}

sub _get_argument_list_content {

    my $self = shift;
    my ($route_parameters_list, $body_parameters_list) = @_;

    my $content_list = [];

    foreach my $param (@{$route_parameters_list}){

        my $param_variable_name = '$' . $param;

        push(@{$content_list}, $param_variable_name);
    }

    foreach my $param (@{$body_parameters_list}){

        my $param_variable_name = '$' . $param;

        push(@{$content_list}, $param_variable_name);
    }

    $self->{_current_argument_list} = $content_list;

    my $content = join(', ', @{$content_list});

    print "content '$content'\n";

    return $content;
}


sub _get_manager_method_content {

    my $self = shift;
    my ($method_name, $url, $desc, $type) = @_;
    
    my $template_file = $self->getManagerMethodTemplateFile();
    if (!defined($template_file)){
        $self->{_logger}->logconfess("template_file was not defined");
    }

    my $lookup = {
        url => $url,
        desc => $desc,
        type => $type,
        method_name => $method_name
    };

    my $content = $self->_generate_content_from_template($template_file, $lookup);

    push(@{$self->{_manager_method_content_list}}, $content);
}

sub _get_dbutil_method_content {

    my $self = shift;
    my ($method_name, $url, $sql, $desc, $type) = @_;
    
    my $template_file;

    if (lc($type) eq 'oracle'){
        $template_file = $self->getOracleDBUtilMethodTemplateFile();
    }
    elsif (lc($type) eq 'mongodb'){
        $template_file = $self->getMongoDBDBUtilMethodTemplateFile();
    }
    elsif (lc($type) eq 'sqlite'){
        $template_file = $self->getSQLiteDBUtilMethodTemplateFile();
    }
    elsif (lc($type) eq 'postgresql'){
        $template_file = $self->getPostgresqlDBUtilMethodTemplateFile();
    }
    elsif (lc($type) eq 'mysql'){
        $template_file = $self->getMySQLDBUtilMethodTemplateFile();
    }
    else {
        $self->{_logger}->logconfess("type '$type' is not supported");
    }
    
    if (!defined($template_file)){
        $self->{_logger}->logconfess("template_file was not defined");
    }

    my $lookup = {
        url  => $url,
        desc => $desc,
        sql  => $sql,
        method_name => $method_name,
        argument_list_content => $self->_get_dbutil_argument_list_content()
    };

    my $content = $self->_generate_content_from_template($template_file, $lookup);

    if (lc($type) eq 'oracle'){
        push(@{$self->{_oracle_dbutil_method_content_list}}, $content);
    }
    elsif (lc($type) eq 'mongodb'){
        push(@{$self->{_mongodb_dbutil_method_content_list}}, $content);
    }
    elsif (lc($type) eq 'sqlite'){
        push(@{$self->{_sqlite_dbutil_method_content_list}}, $content);
    }
    elsif (lc($type) eq 'postgresql'){
        push(@{$self->{_postgresql_dbutil_method_content_list}}, $content);
    }
    elsif (lc($type) eq 'mysql'){
        push(@{$self->{_mysql_dbutil_method_content_list}}, $content);
    }
    else {
        $self->{_logger}->logconfess("type '$type' is not supported");
    }
}

sub _get_dbutil_argument_list_content {

    my $self = shift;

    my $content_list = [];

    foreach my $param (@{$self->{_current_argument_list}}){

        my $template_file = $self->getDBUtilArgumentTemplateFile();
        if (!defined($template_file)){
            $self->{_logger}->logconfess("template_file was not defined");
        }

        my $lookup = { param => $param};

        my $content = $self->_generate_content_from_template($template_file, $lookup);

        push(@{$content_list}, $content);
    }

    my $argument_list_content = 'my (' . join(', ', @{$self->{_current_argument_list}}) . ') = @_;';

    my $content = $argument_list_content . "\n\n" . join("\n\n", @{$content_list});

    return $content;
}

sub _generate_content_from_template {

    my $self = shift;
    my ($template_file, $lookup) = @_;

    my $tt = new Template({ABSOLUTE => 1});
    if (!defined($tt)){
        $self->{_logger}->logconfess("Could not instantiate TT");
    }

    my $tmp_outfile = $self->getOutdir() . '/out.pm';

    $tt->process($template_file, $lookup, $tmp_outfile) || $self->{_logger}->logconfess("Encountered the following Template::process error:" . $tt->error());
    
    $self->{_logger}->info("Wrote temporary output file '$tmp_outfile'");

    my @lines = read_file($tmp_outfile);

    my $content = join("", @lines);

    unlink($tmp_outfile) || $self->{_logger}->logconfess("Could not unlink temporary output file '$tmp_outfile' : $!");

    $self->{_logger}->info("temporary output file '$tmp_outfile' was removed");

    return $content;
}

sub _generate_modules {

    my $self = shift;
    
    my $namespace = $self->getNamespace();
    if (!defined($namespace)){
        $self->{_logger}->logconfess("namespace was not defined");
    }

    my $author = $self->getAuthor();
    if (!defined($author)){
        $self->{_logger}->logconfess("author was not defined");
    }

    my $copyright = $self->getCopyright();
    if (!defined($copyright)){
        $self->{_logger}->logconfess("copyright was not defined");
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

        my $template_file_basename = File::Basename::basename($template_file);

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
                author    => $author,
                copyright => $copyright,
                namespace => $namespace,
                full_namespace => $full_namespace
            };


            if ($template_file_basename eq 'namespace_App_tmpl.tt'){
                
                $self->{_logger}->info("Going to load app methods");

                $final_lookup->{app_methods} = join("\n\n", @{$self->{_app_method_content_list}});
            }
            elsif ($template_file_basename eq 'namespace_Manager_tmpl.tt'){
                
                $self->{_logger}->info("Going to load manager methods");

                $final_lookup->{dbutil_type}  = $self->getDBUtilType();

                $final_lookup->{manager_methods} = join("\n\n", @{$self->{_manager_method_content_list}});
            }
            elsif ($template_file_basename eq 'namespace_MongoDB_DBUtil_tmpl.tt'){

                if (exists $self->{_mongodb_dbutil_method_content_list}){
                    $self->{_logger}->info("Going to load mongodb methods");

                    $final_lookup->{mongodb_methods} = join("\n\n", @{$self->{_mongodb_dbutil_method_content_list}});
                }
            }
            elsif ($template_file_basename eq 'namespace_SQLite_DBUtil_tmpl.tt'){
             
                if (exists $self->{_sqlite_dbutil_method_content_list}){
                    $self->{_logger}->info("Going to load sqlite methods");

                    $final_lookup->{sqlite_methods} = join("\n\n", @{$self->{_sqlite_dbutil_method_content_list}});
                }
            }
            elsif ($template_file_basename eq 'namespace_Oracle_DBUtil_tmpl.tt'){
             
                if (exists $self->{_oracle_dbutil_method_content_list}){
                    $self->{_logger}->info("Going to load oracle methods");

                    $final_lookup->{oracle_methods} = join("\n\n", @{$self->{_oracle_dbutil_method_content_list}});
                }
            }
            elsif ($template_file_basename eq 'namespace_Postgresql_DBUtil_tmpl.tt'){
            
                if (exists $self->{_postgresql_dbutil_method_content_list}){    
                    $self->{_logger}->info("Going to load postgresql methods");

                    $final_lookup->{postgresql_methods} = join("\n\n", @{$self->{_postgresql_dbutil_method_content_list}});
                }
            }
            elsif ($template_file_basename eq 'namespace_MySQL_DBUtil_tmpl.tt'){
            
                if (exists $self->{_mysql_dbutil_method_content_list}){
                    $self->{_logger}->info("Going to load mysql methods");

                    $final_lookup->{mysql_methods} = join("\n\n", @{$self->{_mysql_dbutil_method_content_list}});
                }
            }



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

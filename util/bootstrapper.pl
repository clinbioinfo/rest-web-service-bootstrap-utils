#!/usr/bin/env perl
use strict;
use Cwd;
use Carp;
use Pod::Usage;
use File::Spec;
use File::Path;
use Term::ANSIColor;
use FindBin;

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

use lib "$FindBin::Bin/../lib";

use constant TRUE => 1;

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

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_IS_COMMIT_AND_PUSH => TRUE;

use constant DEFAULT_CONFIG_FILE => "$FindBin::Bin/../conf/bootstrapper.ini";

use constant DEFAULT_VERBOSE   => FALSE;

use constant DEFAULT_LOG_LEVEL => 4;

use constant DEFAULT_INDIR => File::Spec->rel2abs(cwd());

use constant DEFAULT_ADMIN_EMAIL_ADDRESS => '';

use constant DEFAULT_USERNAME =>  getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

use constant DEFAULT_AUTHOR => 'Jaideep Sundaram';

use constant DEFAULT_COPYRIGHT => 'Copyright Jaideep Sundaram';

use REST::WebService::Bootstrapper::Logger;
use REST::WebService::Bootstrapper::Config::Manager;
use REST::WebService::Bootstrapper::Manager;

$|=1; ## do not buffer output stream

## Command-line arguments
my (
    $infile, 
    $outdir,
    $config_file,
    $log_level, 
    $help, 
    $logfile, 
    $man, 
    $verbose,
    $admin_email_address,
    $test_mode,
    $namespace,
    $author,
    $copyright,
    $database,
    $database_account_type,
    $oracle_home,
    $app_config_ini_file,
    $use_database_proxy_account
    );

my $results = GetOptions (
    'log-level|d=s'                  => \$log_level, 
    'logfile=s'                      => \$logfile,
    'config_file=s'                  => \$config_file,
    'help|h'                         => \$help,
    'man|m'                          => \$man,
    'infile=s'                       => \$infile,
    'outdir=s'                       => \$outdir,
    'admin_email_address=s'          => \$admin_email_address,
    'test_mode=s'                    => \$test_mode,
    'namespace=s'                    => \$namespace,
    'author=s'                       => \$author,
    'copyright=s'                    => \$copyright,
    'use_database_proxy_account=s'   => \$use_database_proxy_account, 
    );

&checkCommandLineArguments();

my $logger = new REST::WebService::Bootstrapper::Logger(
    logfile   => $logfile, 
    log_level => $log_level
    );

if (!defined($logger)){
    die "Could not instantiate REST::WebService::Bootstrapper::Logger";
}

my $config_manager = REST::WebService::Bootstrapper::Config::Manager::getInstance(config_file => $config_file);
if (!defined($config_manager)){
    $logger->logdie("Could not instantiate REST::WebService::Bootstrapper::Config::Manager");
}

my $manager = REST::WebService::Bootstrapper::Manager::getInstance(
    infile    => $infile,
    outdir    => $outdir,
    test_mode => $test_mode,
    namespace => $namespace,
    author    => $author,
    copyright => $copyright
    );

if (!defined($manager)){
    $logger->logdie("Could not instantiate REST::WebService::Bootstrapper::Manager");
}

if (defined($database)){
    $manager->setDatabase($database);
}

if (defined($database_account_type)){
    $manager->setDatabaseAccountType($database_account_type);
}

if (defined($oracle_home)){
    $manager->setOracleHome($oracle_home);
}

if (defined($app_config_ini_file)){
    $manager->setAppConfigIniFile($app_config_ini_file);
}

if (defined($use_database_proxy_account)){
    $manager->setUseDatabaseProxyAccount($use_database_proxy_account);
}

$manager->run();

printGreen(File::Spec->rel2abs($0) . " execution completed\n");

print "The log file is '$logfile'\n\n";

print "Next steps:\n";
print "===========\n\n";

print "1. Make sure to adjust the settings in the application configuration file (conf/app_config.ini).\n";
print "2. Copy assets that were just generated (bin/app.psgi, all lib/**/*.pm files and the conf/app_config.ini) to your Dancer framework directory.\n";
print "3. Launch your Dancer application.\n\n";
print "Take a look at the dancer_helper.pl utility program in the dev-utils code-base.\n\n";

exit(0);

##-----------------------------------------------------------
##
##    END OF MAIN -- SUBROUTINES FOLLOW
##
##-----------------------------------------------------------

sub checkCommandLineArguments {
   
    if ($man){
    	&pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});
    }
    
    if ($help){
    	&pod2usage({-exitval => 1, -verbose => 1, -output => \*STDOUT});
    }

    if (!defined($database)){

        $database = DEFAULT_DATABASE;

        printYellow("--database was not specified and therefore was set to default '$database'");
    }

    if (!defined($use_database_proxy_account)){

        $use_database_proxy_account = DEFAULT_USE_DATABASE_PROXY_ACCOUNT;

        printYellow("--use_database_proxy_account was not specified and therefore was set to default '$use_database_proxy_account'");
    }

    if (!defined($oracle_home)){

        $oracle_home = DEFAULT_ORACLE_HOME;

        printYellow("--oracle_home was not specified and therefore was set to default '$oracle_home'");
    }

    if (!defined($database_account_type)){

        $database_account_type = DEFAULT_DATABASE_ACCOUNT_TYPE;

        printYellow("--database_account_type was not specified and therefore was set to default '$database_account_type'");
    }

    if (!defined($app_config_ini_file)){

        $app_config_ini_file = DEFAULT_APP_CONFIG_INI_FILE;

        printYellow("--app_config_ini_file was not specified and therefore was set to default '$app_config_ini_file'");
    }

    if (!defined($test_mode)){

        $test_mode = DEFAULT_TEST_MODE;
            
        printYellow("--test_mode was not specified and therefore was set to default '$test_mode'");
    }

    if (!defined($config_file)){

        $config_file = DEFAULT_CONFIG_FILE;
            
        printYellow("--config_file was not specified and therefore was set to '$config_file'");
    }

    &checkInfileStatus($config_file);

    if (!defined($verbose)){

        $verbose = DEFAULT_VERBOSE;

        printYellow("--verbose was not specified and therefore was set to '$verbose'");
    }

    if (!defined($log_level)){

        $log_level = DEFAULT_LOG_LEVEL;

        printYellow("--log_level was not specified and therefore was set to '$log_level'");
    }

    if (!defined($admin_email_address)){

        $admin_email_address = DEFAULT_ADMIN_EMAIL_ADDRESS;

        printYellow("--admin-email-address was not specified and therefore was set to '$admin_email_address'");
    }

    if (!defined($author)){

        $author = DEFAULT_AUTHOR;

        printYellow("--author was not specified and therefore was set to '$author'");
    }

    if (!defined($copyright)){

        $copyright = DEFAULT_COPYRIGHT;

        printYellow("--copyright was not specified and therefore was set to '$copyright'");
    }

    if (!defined($outdir)){

        $outdir = DEFAULT_OUTDIR;

        printYellow("--outdir was not specified and therefore was set to '$outdir'");
    }

    $outdir = File::Spec->rel2abs($outdir);

    if (!-e $outdir){

        mkpath ($outdir) || die "Could not create output directory '$outdir' : $!";

        printYellow("Created output directory '$outdir'");

    }
    
    if (!defined($logfile)){

    	$logfile = $outdir . '/' . File::Basename::basename($0) . '.log';

    	printYellow("--logfile was not specified and therefore was set to '$logfile'");

    }

    $logfile = File::Spec->rel2abs($logfile);

    my $fatalCtr=0;

    if (!defined($namespace)){

        printBoldRed("--namespace was not specified");

        $fatalCtr++;
    }

    if (!defined($infile)){

        printBoldRed("--infile was not specified");

        $fatalCtr++;
    }
    else {
        $infile = File::Spec->rel2abs($infile);

        &checkInfileStatus($infile);
    }


    if ($fatalCtr> 0 ){

    	printBoldRed("Required command-line arguments were not specified");

        exit(1);
    }
}

sub printBoldRed {

    my ($msg) = @_;
    print color 'bold red';
    print $msg . "\n";
    print color 'reset';
}

sub printYellow {

    my ($msg) = @_;
    print color 'yellow';
    print $msg . "\n";
    print color 'reset';
}

sub printGreen {

    my ($msg) = @_;
    print color 'green';
    print $msg . "\n";
    print color 'reset';
}


sub checkOutdirStatus {

    my ($outdir) = @_;

    if (!-e $outdir){
        
        mkpath($outdir) || die "Could not create output directory '$outdir' : $!";
        
        printYellow("Created output directory '$outdir'");
    }
    
    if (!-d $outdir){

        printBoldRed("'$outdir' is not a regular directory\n");
    }
}


sub checkInfileStatus {

    my ($infile) = @_;

    if (!defined($infile)){
        die ("infile was not defined");
    }

    my $errorCtr = 0 ;

    if (!-e $infile){

        printBoldRed("input file '$infile' does not exist");

        $errorCtr++;
    }
    else {

        if (!-f $infile){

            printBoldRed("'$infile' is not a regular file");

            $errorCtr++;
        }

        if (!-r $infile){

            printBoldRed("input file '$infile' does not have read permissions");

            $errorCtr++;
        }
        
        if (!-s $infile){

            printBoldRed("input file '$infile' does not have any content");

            $errorCtr++;
        }
    }
     
    if ($errorCtr > 0){

        printBoldRed("Encountered issues with input file '$infile'");

        exit(1);
    }
}




__END__

=head1 NAME

 commit_code.pl - Perl script for committing code to Git and then add comment to relevant Jira ticket


=head1 SYNOPSIS

 perl util/commit_code.pl --issue_id BDMTNG-552

=head1 OPTIONS

=over 8

=item B<--outdir>

  The directory where all output artifacts will be written e.g.: the log file
  if the --logfile option is not specified.
  A default value is assigned /tmp/[username]/bootstrapper.pl/[timestamp]/

=item B<--log_level>

  The log level for Log4perl logging.  
  Default is set to 4.

=item B<--logfile>

  The Log4perl log file.
  Default is set to [outdir]/bootstrapper.pl.log

=item B<--help|-h>

  Print a brief help message and exits.

=item B<--man|-m>

  Prints the manual page and exits.


=back

=head1 DESCRIPTION

 TBD

=head1 CONTACT

 Jaideep Sundaram 

 Copyright Jaideep Sundaram

 Can be distributed under GNU General Public License terms

=cut

package REST::WebService::Bootstrapper::File::XML::Twig::Parser;

use Moose;
use Data::Dumper;
use XML::Twig;

extends 'REST::WebService::Bootstrapper::File::XML::Parser';

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_EXPIRY => 0;

use constant DEFAULT_METHOD => 'GET';

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_USERNAME => getlogin || getpwuid($<) || $ENV{USER} || "sundaramj";

use constant DEFAULT_OUTDIR => '/tmp/' . DEFAULT_USERNAME . '/' . File::Basename::basename($0) . '/' . time();

## Singleton support
my $instance;

my $this;

sub getInstance {

    if (!defined($instance)){

        $instance = new REST::WebService::Bootstrapper::File::XML::Twig::Parser(@_);

        if (!defined($instance)){

            confess "Could not instantiate REST::WebService::Bootstrapper::File::XML::Twig::Parser";
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
    my ($infile) = @_;

    if (!defined($infile)){

        $infile = $self->getInfile();

        if (!defined($infile)){
            $self->{_logger}->logconfess("infile was not defined");
        }
    }

    $self->_checkInfileStatus($infile);

    $this = $self;

    my $twig = new XML::Twig( 
       twig_handlers =>  { 
           'end-point'   => \&_end_point_callback,
       });
   
    if (!defined($twig)){
        $self->{_logger}->logconfess("Could not instantiate XML::Twig for file '$infile'");
    }

    $twig->parsefile( $infile );

    $self->{_logger}->info("Finished parsing install configuration XML file '$infile'");
}

sub _end_point_callback {

    my $self = $this;
    my ($twig, $end_point) = @_;
      
    if (! $end_point->has_child('name')){
        $self->{_logger}->logconfess("end-point does not have child name " . Dumper $end_point);
    }

    my $name = $end_point->first_child('name')->text();

    if (! $end_point->has_child('url')){
        $self->{_logger}->logconfess("end-point does not have child url " . Dumper $end_point);
    }

    my $url = $end_point->first_child('url')->text();


    my $desc = 'N/A';

    if (! $end_point->has_child('desc')){
        $self->{_logger}->warn("end-point does not have child name " . Dumper $end_point);
    }
    else {
        $desc = $end_point->first_child('desc')->text();
    }


    my $label = 'N/A';

    if (! $end_point->has_child('label')){
        $self->{_logger}->warn("end-point does not have child label " . Dumper $end_point);
    }
    else {
        $label = $end_point->first_child('label')->text();
    }

    my $label_desc = 'N/A';

    if (! $end_point->has_child('label-desc')){
        $self->{_logger}->warn("end-point does not have child label-desc " . Dumper $end_point);
    }
    else {
        $label_desc = $end_point->first_child('label-desc')->text();
    }

    my $expiry = DEFAULT_EXPIRY;

    if (! $end_point->has_child('expiry')){
        $self->{_logger}->warn("end-point does not have child expiry " . Dumper $end_point);
    }
    else {
        $expiry = $end_point->first_child('expiry')->text();
    }



    my $method;

    if (! $end_point->has_child('method')){

        $self->{_logger}->warn("end-point does not have child method " . Dumper $end_point);
        
        $method = DEFAULT_METHOD;
        
        $self->{_logger}->info("method was not defined and therefore was set to default '$method'");
    }
    else {
        $method = $end_point->first_child('method')->text();
    }

    if (! $end_point->has_child('type')){
        $self->{_logger}->logconfess("end-point does not have child url " . Dumper $end_point);
    }

    my $type = $end_point->first_child('type')->text();

    my $sql;

    if ((lc($type) eq 'oracle')    || 
        (lc($type) eq 'mysql')     || 
        (lc($type) eq 'postgreql') || 
        (lc($type) eq 'sqlite')    ||
        (lc($type) eq 'mongodb')){

        if (! $end_point->has_child('sql')){
            $self->{_logger}->warn("end-point with type '$type' does not have child sql " . Dumper $end_point);
        }
        else {
            $sql= $end_point->first_child('sql')->text();
        }
    }

    my $route_parameters_list = $self->_get_route_parameters_list($url, $name);

    my $body_parameters_list = [];

    if ($end_point->has_child('body-parameters-list')){

        my $body_parameters_list_elem = $end_point->first_child('body-parameters-list');

        if ($body_parameters_list_elem->has_child('body-param')){
            
            my $body_param = $body_parameters_list_elem->first_child('body-param');
            
            my $body_param_text = $body_param->text();

            if ((defined($body_param_text)) && ($body_param_text ne '')){
                
                push(@{$body_parameters_list}, $body_param_text);
            }

            while ($body_param = $body_param->next_sibling()){

                my $body_param_text = $body_param->text();
                
                if ((defined($body_param_text)) && ($body_param_text ne '')){
                
                    push(@{$body_parameters_list}, $body_param_text);
                }
            }
        }
        else {
            $self->{_logger}->info("body-parameters-list does not have a body-param for end-point " . Dumper $end_point);            
        }
    }
    else {
        $self->{_logger}->info("end-point with name '$name' does not have any body-parameters-list element");
    }

    my $table_list = [];

    if (lc($method) eq 'post'){

        if ($end_point->has_child('target-tables')){

            $self->_process_target_collections($end_point, $table_list, 'target-tables', 'table');
        }
        else {
            $self->{_logger}->warn("target-tables was not defined for end-point " . Dumper $end_point);            
        }

        ##
        ## Will treat the collections as if they are tables for processing purposes.
        ##

        if ($end_point->has_child('target-collections')){

            $self->_process_target_collections($end_point, $table_list, 'target-collections', 'collection');
        }
        else {
            $self->{_logger}->warn("target-collections was not defined for end-point " . Dumper $end_point);
        }
    }


    $self->_create_endpoint_record($name, $url, $desc, $method, $type, $sql, $route_parameters_list, $body_parameters_list, $table_list, $label, $label_desc, $expiry);
}


 
sub _process_target_collections {

    my $self = shift;
    my ($end_point, $table_list, $targets, $target_type) = @_;

    my $target_tables_elem = $end_point->first_child($targets);

    if ($target_tables_elem->has_child($target_type)){
    
        my $table_elem = $target_tables_elem->first_child($target_type);
        
        my $table_name = $table_elem->text();

        if ((defined($table_name)) && ($table_name ne '')){
            
            push(@{$table_list}, $table_name);
        }

        while ($table_elem = $table_elem->next_sibling()){

            my $table_name = $table_elem->text();
            
            if ((defined($table_name)) && ($table_name ne '')){
            
                push(@{$table_list}, $table_name);
            }
        }
    }
}


sub _get_route_parameters_list {

    my $self = shift;
    my ($url, $name) = @_;

    my @parts = split(/\//, $url);

    my $list = [];
    my $ctr = 0;

    foreach my $part (@parts){
    
        if ($part =~ m|\:(\S+)|){
            push(@{$list}, $1);
            $ctr++;
        }
    }

    $self->{_logger}->info("Found '$ctr' route parameters for end-point with name '$name'");

    return $list;
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

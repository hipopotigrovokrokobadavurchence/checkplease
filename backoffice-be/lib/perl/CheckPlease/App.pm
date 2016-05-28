package CheckPlease::App;
use strict;
use warnings;

use CGI;
use Data::Dumper;
use Try::Tiny;
use JSON;
use DBI;

sub new($)
{
    my ($class) = @_;
    my $self = { };
    bless $self, $class;

    binmode STDOUT, ':utf8';
    binmode STDERR, ':utf8';

    return $self;

}

sub ASSERT($;$)
{
    my($cond, $msg) = @_;

    if($cond)
    {
    }
    else
    {
        $msg //= "";
        TRACE("aaaaaaaa",$msg);
        die $msg;
    }
}

sub TRACE($;$)
{
    my($string, $object)=@_;
    $object //= '';
    print STDERR "\n",$string,$object;
}

my $command_map =
{
    create_or_update_menu_items => { proc => \&CreateOrUpdateMenuItem },
    create_or_update_menu_category => { proc => \&CreateOrUpdateMenuCategory }
};

sub Handler ($)
{
    my ($self) = @_;

    my $response;

    try
    {
        my $cgi = CGI->new() ; 
        my $payload_jsonrpc = $cgi->param('payload_jsonrpc');
        TRACE("aaaaaaaaa",Dumper $self);

        $$self{cgi}{payload_jsonrpc} = $payload_jsonrpc;
        TRACE("\nCGI: ", Dumper $$self{cgi});
        #$dbdrv:dbname=$dbname;host=$dbhost;port=$dbport;$dsn_params
        #$dsn,
        #                    $dbuser,
        #                                        $dbauth,
        #                                                            $connParams ) or throw($dsn . ": ". $DBI::errstr);
        my $dsn = "dbi:Pg:dbname='places';host='127.0.0.1';port='5432';";
        my $dbuser = "app_api1";
        my $dbauth = "123";
        my $connParams = { AutoCommit => 1};
        $$self{dbh} = DBI->connect($dsn, $dbuser, $dbauth, $connParams);

        ASSERT(defined $$self{cgi}{payload_jsonrpc},"NO payload_jsonrpc");
        my $payload = decode_json($$self{cgi}{payload_jsonrpc});
        my $method = $$payload{method};
        my $params = $$payload{params};


        TRACE("cccc",Dumper $command_map);
        TRACE("dddd",Dumper $method);
        my $cmd_handler = $$command_map{ $method };
        ASSERT(defined $cmd_handler, "No such method in API v.2.00");
        
        my $response_f = $$cmd_handler{proc}->($self, $params);
        $response = encode_json( $response_f );
        
    }
    catch 
    {
        $response = '{"error":"'.$_.'"}';
    };
    print CGI::header(-charset => 'utf-8',
                          -type => 'application/json-rpc',
                          -Access_Control_Allow_Origin => '*',
                          -Access_Control_Allow_Headers => "Origin, X-Requested-With, Content-Type, Accept"
                      );
    TRACE("RESPONSE: ",$response);
    print $response;

}

sub CreateOrUpdateMenuItem($$)
{
    my($self, $params) = @_;

    ASSERT(defined $$params{name},"Missing name");
    ASSERT(defined $$params{descr},"Missing description");
    ASSERT(defined $$params{price},"Missing price");
    ASSERT(defined $$params{place_id__id_hash}, "Missing place");

    my $sth = $$self{dbh}->prepare("SELECT id FROM places WHERE id_hash = ?");
    $sth->execute($$params{place_id__id_hash});
    ASSERT(defined $sth->rows == 1,"No such place!");

    my $place_id_hash = $sth->fetchrow_hashref;
    my $place_id = $$place_id_hash{id};
    my $cond = undef;
    my $id_hash = delete $$params{id_hash};
    $$params{operation} //= '';
    delete $$params{place_id__id_hash};
    TRACE("operation: ",$$params{operation});
    if($$params{operation} eq "insert")
    {
        $cond = undef;

    }
    elsif($$params{operation} eq "update" )
    {
        $cond = {id_hash => $id_hash};
    }
    else
    {
        ASSERT(0,"Not valid method");
    }
    delete $$params{operation};
    
    return CreateOrUpdate($$self{dbh},"menu_items", $params, $cond);


}

sub CreateOrUpdate ($$$;$)
{
    my ($dbh, $table_name, $params, $cond) = @_;

    my$sth ;
    
    if(defined $cond)
    {
        my @update_arr;
        foreach my $key (keys %$params)
        {
            if(defined($$params{$key}))
            {
                push @update_arr, " $key=".$dbh->quote($$params{$key}) ;
            }
        }
        my @cond_arr;
        foreach my $key (keys %$cond)
        {
            if(defined($$cond{$key}))
            {
                push @cond_arr, " $key=".$dbh->quote($$cond{$key}) ;
            }
            else
            {
                push @cond_arr, " $key IS NULL ";
            }
        }

        my $params_str = join ' , ', @update_arr;
        my $cond_str = join ' , ', @cond_arr;
        $sth = $dbh->prepare("UPDATE $table_name SET $params_str WHERE $cond_str RETURNING *");
        $sth->execute();
        ASSERT($sth->rows == 1,"rows".$sth->rows);
    }
    else
    {
        my @column_names_arr;
        my @column_values_arr;
        for my $key (keys %$params)
        {
            push @column_names_arr, $key;
            push @column_values_arr, $dbh->quote($$params{$key});

        }
        
        my $column_names_str = join ' , ', @column_names_arr;
        my $column_values_str = join ' , ', @column_values_arr;
        $sth = $dbh->prepare("INSERT INTO $table_name ($column_names_str) VALUES($column_values_str) RETURNING *");
        $sth->execute();
        ASSERT($sth->rows == 1,"rows".$sth->rows);

    }


    return $sth->fetchrow_hashref;
}




1;

package CheckPlease::App;
use strict;
use warnings;

use CGI;
use Data::Dumper;
use Try::Tiny;
use JSON;
use DBI;
use MIME::Base64;

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
    get_menu_items => { proc => \&GetMenuItems},
    create_or_update_menu_category => { proc => \&CreateOrUpdateMenuCategory },
    get_menu_categories => { proc => \&GetMenuCategories},
    create_or_update_tables => {proc => \&CreateOrUpdateTables },
    get_tables => {proc => \&GetTables},
    create_or_update_places => {proc => \&CreateOrUpdatePlaces },
    get_places => {proc => \&GetPlaces},

};

sub Handler ($)
{
    my ($self) = @_;

    my $response;

    my $cgi = CGI->new() ; 
    try
    {
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
        my $connParams = { AutoCommit => 1, RaiseError => 1, PrintError => 0};
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

        TRACE("response: ",Dumper $response_f);
        $response = encode_json( {result => $response_f} );
        
        $$self{dbh}->commit;
        
    }
    catch 
    {
        $response = '{"error":"'.$_.'"}';
        #$$self{dbh}->rollback;
    };
#    print $cgi->header(-charset => 'utf-8',
#                          -type => 'application/json',
#                          -Access_Control_Allow_Origin => '*',
#                          -Access_Control_Allow_Headers => "Origin, X-Requested-With, Content-Type, Accept"
#                     );
    #print $cgi->header('application/json-rpc');
print $cgi->header(
-type => 'text/plain',
-access_control_allow_origin => '*',
-access_control_allow_headers => 'content-type,X-Requested-With',
-access_control_allow_methods => 'GET,POST,OPTIONS',
-access_control_allow_credentials => 'true',
);
    TRACE("RESPONSE: ",$response);
    print $response;

}

sub GetTables($$)
{
    my ($self, $params)=@_;

    my $place_id = $$params{place_id} || 0 ;
    my $place_id_hash = $$params{place_id__id_hash} || '0';

    my $sth = $$self{dbh}->prepare(q{
        SELECT T.*, P.id_hash as  place_id__id_hash
        FROM tables T
            JOIN places P ON P.id = T.place_id
        WHERE T.is_deleted is false AND (T.place_id = ? OR P.id_hash = ?)
        });
    $sth->execute($place_id, $place_id_hash);

    my @result;
    while (my $row= $sth->fetchrow_hashref)
    {
        push @result, $row;
    }
    return \@result;

}


sub GetPlaces($$)
{
    my ($self, $params)=@_;


    my $sth = $$self{dbh}->prepare(q{
        SELECT P.*
        FROM places P
        WHERE P.is_deleted is false
        });
    $sth->execute();


    my @result;
    while (my $row= $sth->fetchrow_hashref)
    {
        push @result, $row;
    }
    return \@result;

}

sub GetMenuItems($$)
{
    my ($self, $params)=@_;

    my $place_id = $$params{place_id} || 0 ;
    my $place_id_hash = $$params{place_id__id_hash} || '0';

    my $sth = $$self{dbh}->prepare(q{
        SELECT MI.*, P.id_hash as  place_id__id_hash
        FROM menu_items MI
            JOIN places P ON P.id = MI.place_id
            LEFT JOIN menu_categories MC ON MC.id = MI.menu_category_id
        WHERE MI.is_deleted is false AND (MI.place_id = ? OR P.id_hash = ?)
		ORDER BY id
    });
    $sth->execute($place_id, $place_id_hash);


    my @result;
    while (my $row= $sth->fetchrow_hashref)
    {
        push @result, $row;
    }
    return \@result;

}

sub GetMenuCategories($$)
{
    my ($self, $params)=@_;

    my $place_id = $$params{place_id} || 0 ;
    my $place_id_hash = $$params{place_id__id_hash} || '0';

    my $sth = $$self{dbh}->prepare(q{
        SELECT MC.*, P.id_hash as  place_id__id_hash
        FROM menu_categories MC
            JOIN places P ON P.id = MC.place_id
        WHERE MC.is_deleted is false AND (MC.place_id = ? OR P.id_hash = ?)
    });
    $sth->execute($place_id, $place_id_hash);

    my @result;
    while (my $row= $sth->fetchrow_hashref)
    {
        push @result, $row;
    }
    return \@result;
}

sub CreateOrUpdatePlaces($$)
{
    my($self, $params) = @_;

    ASSERT(defined $$params{operation},"Missing operation!");
    TRACE("params: ",Dumper $params);
    if($$params{operation} ne "delete")
    {
        #ASSERT(defined $$params{number},"Missing table number");
        #ASSERT(defined $$params{descr},"Missing ");
        ASSERT(defined $$params{preferences_json},"Missing preferences_json");
        $$params{preferences_json} = encode_json($$params{preferences_json});
        $$params{inserted_by} //= 1;
        $$params{updated_by} //= 1;
    }
    #operations switch
    my $cond = undef;
    my $id_hash = delete $$params{id_hash};
    my $id = delete $$params{id};
    if($$params{operation} eq "insert")
    {   
        $cond = undef;
    }
    elsif($$params{operation} eq "update" || $$params{operation} eq "delete")
    {   
        if(defined $id_hash)
        {
            $cond = {id_hash => $id_hash};
        }
        elsif(defined $id)
        {
            $cond = {id => $id};
        }
        else
        {
            ASSERT(0,"No category id or id_has for this opeation");
        }
    }
    else
    {
        ASSERT(0,"Not valid operation");
    }
    my $operation = delete $$params{operation};

    return CreateOrUpdate($$self{dbh},"places", $params, $cond, $operation);


}
sub CreateOrUpdateTables($$)
{
    my($self, $params) = @_;

    ASSERT(defined $$params{operation});
    if($$params{operation} ne "delete")
    {
        ASSERT(defined $$params{number},"Missing table number");
        #ASSERT(defined $$params{descr},"Missing ");
        ASSERT(defined $$params{place_id} || defined $$params{place_id__id_hash},"Missing Place");

        my $place_id;
        if(!defined $$params{place_id})
        {
            my $sth = $$self{dbh}->prepare("SELECT id FROM places WHERE id_hash = ?");
            $sth->execute($$params{place_id__id_hash});
            ASSERT(defined $sth->rows == 1,"No such place!");

            my $place_id_hash = $sth->fetchrow_hashref;
            $place_id = $$place_id_hash{id};
            delete $$params{place_id__id_hash};

        }

        $$params{place_id} //= $place_id;
        $$params{inserted_by} //= 1;
        $$params{updated_by} //= 1;
    }
    #operations switch
    my $cond = undef;
    my $id_hash = delete $$params{id_hash};
    my $id = delete $$params{id};
    if($$params{operation} eq "insert")
    {   
        $cond = undef;
    }
    elsif($$params{operation} eq "update" || $$params{operation} eq "delete")
    {   
        if(defined $id_hash)
        {
            $cond = {id_hash => $id_hash};
        }
        elsif(defined $id)
        {
            $cond = {id => $id};
        }
        else
        {
            ASSERT(0,"No category id or id_has for this opeation");
        }
    }
    else
    {
        ASSERT(0,"Not valid operation");
    }
    my $operation = delete $$params{operation};

    return CreateOrUpdate($$self{dbh},"tables", $params, $cond, $operation);


}

sub CreateOrUpdateMenuCategory($$)
{
    my($self, $params) = @_;

    ASSERT(defined $$params{operation});
    if($$params{operation} ne "delete")
    {
        ASSERT(defined $$params{name},"Missing name");
        #ASSERT(defined $$params{descr},"Missing ");
        ASSERT(defined $$params{place_id} || defined $$params{place_id__id_hash},"Missing Place");

        my $place_id;
        if(!defined $$params{place_id})
        {
            my $sth = $$self{dbh}->prepare("SELECT id FROM places WHERE id_hash = ?");
            $sth->execute($$params{place_id__id_hash});
            ASSERT(defined $sth->rows == 1,"No such place!");

            my $place_id_hash = $sth->fetchrow_hashref;
            $place_id = $$place_id_hash{id};
            delete $$params{place_id__id_hash};

        }

        $$params{place_id} //= $place_id;
        $$params{inserted_by} //= 1;
        $$params{updated_by} //= 1;
    }
    #operations switch
    my $cond = undef;
    my $id_hash = delete $$params{id_hash};
    my $id = delete $$params{id};
    if($$params{operation} eq "insert")
    {   
        $cond = undef;
    }
    elsif($$params{operation} eq "update" || $$params{operation} eq "delete")
    {   
        if(defined $id_hash)
        {
            $cond = {id_hash => $id_hash};
        }
        elsif(defined $id)
        {
            $cond = {id => $id};
        }
        else
        {
            ASSERT(0,"No category id or id_has for this opeation");
        }
    }
    else
    {
        ASSERT(0,"Not valid operation");
    }
    my $operation = delete $$params{operation};

    return CreateOrUpdate($$self{dbh},"menu_categories", $params, $cond, $operation);


}

sub CreateOrUpdateMenuItem($$)
{
    my($self, $params) = @_;

    ASSERT(defined $$params{operation});
    if($$params{operation} ne "delete")
    {
        ASSERT(defined $$params{name},"Missing name");
        #ASSERT(defined $$params{descr},"Missing description");
        ASSERT(defined $$params{price},"Missing price");
        ASSERT(defined $$params{place_id__id_hash}, "Missing place");

        my $sth = $$self{dbh}->prepare("SELECT id FROM places WHERE id_hash = ?");
        $sth->execute($$params{place_id__id_hash});
        ASSERT(defined $sth->rows == 1,"No such place!");

        my $place_id_hash = $sth->fetchrow_hashref;
        my $place_id = $$place_id_hash{id};
        $$params{place_id} = $place_id;
        $$params{inserted_by} //= 1;
        $$params{updated_by} //= 1;

        delete $$params{place_id__id_hash};
    }
    my $cond = undef;
    TRACE("operation: ",$$params{operation});
    my $id_hash = delete $$params{id_hash};
    my $id = delete $$params{id};

    if($$params{operation} eq "insert")
    {
        $cond = undef;

    }
    elsif($$params{operation} eq "update" || $$params{operation} eq "delete")
    {
        if(defined $id_hash)
        {
            $cond = {id_hash => $id_hash};
        }
        elsif(defined $id)
        {
            $cond = {id => $id};
        }
        else
        {   
            ASSERT(0,"No category id or id_has for this opeation");
        }
    }
    else
    {
        ASSERT(0,"Not valid method");
    }
    delete $$params{operation};
	my $image_base64 = delete $$params{image_base64};
    my $result_hash = CreateOrUpdate($$self{dbh},"menu_items", $params, $cond);
    if(defined $image_base64)
    {
        GenerateImage($image_base64,"/usr/share/HackFMI/checkplease/images/".$$result_hash[0]{id_hash}.".jpg");    
		
		#$result[0]->[0]->{id_hash} =
 		$$result_hash[0]{image_url} = "http://http://192.168.1.2:7777/appa/menu_images/".$$result_hash[0]{id_hash}."jpg"
    }
    return $result_hash;

}

sub GenerateImage($$)
{
	my ($image_base_64,$image_name)=@_;

	my $data = decode_base64($image_base_64);


	my $fh = IO::File->new($image_name, "w") or die($!);
	print $fh $data;

	$fh->close;


}


sub CreateOrUpdate ($$$;$$)
{
    my ($dbh, $table_name, $params, $cond, $operation) = @_;

    my$sth ;
    
    if(defined $cond)
    {
        my @update_arr;
        foreach my $key (keys %$params)
        {
            if(defined($$params{$key}))
            {
                push @update_arr, " ".$dbh->quote_identifier($key)."=".$dbh->quote($$params{$key}) ;
            }
        }
        my @cond_arr;
        foreach my $key (keys %$cond)
        {
            if(defined($$cond{$key}))
            {
                push @cond_arr, " ".$dbh->quote_identifier($key)."=".$dbh->quote($$cond{$key}) ;
            }
            else
            {
                push @cond_arr, " ".$dbh->quote_identifier($key) ." IS NULL ";
            }
        }

        my $params_str = join ' , ', @update_arr;
        my $cond_str = join ' , ', @cond_arr;
        if(defined $operation && $operation eq 'delete')
        {
            my $q_str = "UPDATE $table_name SET is_deleted = true WHERE $cond_str AND is_deleted=false RETURNING *";
            TRACE("operation delete, query: ", $q_str);
            $sth = $dbh->prepare($q_str);
            $sth->execute();
            ASSERT($sth->rows ==1,"You can delete only one row!");
        }
        else
        {
            TRACE("UPDATE $table_name SET $params_str WHERE $cond_str RETURNING *");
            $sth = $dbh->prepare("UPDATE $table_name SET $params_str WHERE $cond_str RETURNING *");
            $sth->execute();
            #ASSERT($sth->rows == 1,"rows".$sth->rows);
        }
    }
    else
    {
        my @column_names_arr;
        my @column_values_arr;
        for my $key (keys %$params)
        {
            push @column_names_arr, $dbh->quote_identifier($key);
            push @column_values_arr, $dbh->quote($$params{$key});

        }
        
        my $column_names_str = join ' , ', @column_names_arr;
        my $column_values_str = join ' , ', @column_values_arr;
        $sth = $dbh->prepare("INSERT INTO $table_name ($column_names_str) VALUES($column_values_str) RETURNING *");
        $sth->execute();
        #ASSERT($sth->rows == 1,"rows".$sth->rows);

    }


    my @result;
    while (my $row= $sth->fetchrow_hashref)
    {
        push @result, $row;
    }
    return \@result;
}




1;

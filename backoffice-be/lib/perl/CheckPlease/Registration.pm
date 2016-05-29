use DBI;
use DBD:Pg;

my $dbh = DBI->connect("dbi:Pg:dbname=", "", "");

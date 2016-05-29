#!/usr/bin/perl
use strict;

use lib  '/usr/share/HackFMI/checkplease/backoffice-be/lib/perl';

use CheckPlease::App ;


#my $r = Apache2::Request->new();
#print qq(Content-type: application/json\n\n);
#print qq(Access-Control-Allow-Origin: *\n\n);

my $app = CheckPlease::App->new();
$app->CheckPlease::App::Handler();








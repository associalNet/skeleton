use strict;
use warnings;
use Plack::Builder;
use HTTP::Router::Declare;
use Plack::Request;
use Plack::Response;
use Plack::App::File;
use Plack::Middleware::Static;
use JSON qw( encode_json decode_json );
use utf8;

use App::Services;

use App::Schema qw();
my $schema = App::Schema->connect('dbi:mysql:database=app', 'app', 'app');

my $router = router {
  match '/{action}/{id}';
};

my $app = sub {
  my $env = shift;

  my $req   = Plack::Request->new($env);
  my $match = $router->match($req)
    or return $req->new_response(404)->finalize;
  my $p = $match->params;

  my $controller = 'App::Services';

  my $action = $controller->can(lc($req->method) . "_" .$p->{action})
    or return $req->new_response(405)->finalize;
  my ($row) = $req->content;
  $p = JSON::decode_json($row) if $row;
  my $res = $req->new_response(200);
  $res->body($controller->$action($p, $schema));
  $res->finalize;
};

builder {
  # I prefer to use apache configuration
  # thus perl app is routed to :80/app
  # and static files are provided by apache server itself
  # though below is for perl handle of static content and lets us use debug panel during dev process
  enable "Plack::Middleware::Static", path => qr{^/(img|js|bower_components|views|css)/}, root => './public/';
#  enable "Debug";
#  enable "Debug::ModuleVersions";
#  enable "Debug::Profiler::NYTProf";
  mount '/' => Plack::App::File->new(file => 'public/index.html')->to_app;

  mount '/app' => builder {
    enable '+App::JSon'; # any output in JSON format with correct status
    $app;
  };
};

=put
=head1 NAME
app.pl - script for psgi server (starman)

=head2 How to start/stop
This script is called from commandline. The "start" script is for the same (please change the PERL5LIB variable before starting):

plackup -I lib bin/app.pl &

can be stopped using 

kill (PID)

=item $schema
Creates a DBIx::Class::Schema object to use during ongoing calls.

=item $router
Describes pattern match for our requests. GET requests shall call "action" with "id" parameter. For more complicatd calls use POST requests.

=item $app
Declaration of our app.
If request does not match regex reply 404 response;
If our controlling module "can not" perform the method - reply 405.
Get json content if any.
And call controller providing it hash of parameters and schema.

=item builder
For real applications we should use apache httpd to provide static data (scripts, images etc.).
Example config is in ../config/01_app.conf
First we enable static data, then declare our application on route "/app"
The app has got App::JSon wrapper.

=cut

use strict;
use Test::More;
use Data::Dumper;
use App::Schema qw();
use lib './lib/';
use lib './t/';

BEGIN {
  use_ok 'App::Services';
  use_ok 'Test::DB';
};

Test::DB::init_db();

my $schema = App::Schema->connect('dbi:SQLite:dbname=t/app.db', '', '',
    { AutoCommit => 1, RaiseError => 1 });

ok $schema, 'schema should not be undef';
use Data::Dumper;

my $app = {};
bless $app, 'App::Services';
isa_ok $app, 'App::Services';

#
# findNode()
#
#my ($id, $parent) = App::Services::findNode(1, $schema);
my ($id, $parent) = $app->findNode(1, $schema);
is $id, '1', "Master node id should be 1";
is $parent, undef, "Master node parent should be undef";

($id, $parent) = $app->findNode(6, $schema);
is $id, 6, "Node #6 id should be 6";
is $parent, 3, "Node #6 parent should be 3";

($id, $parent) = $app->findNode(666, $schema);
is $id, undef, "Node #666 id should be undef";
is $parent, undef, "Node #666 parent should be undef";

#
# get_nodes()
#


my $node = $app->get_nodes({id => 1}, $schema);
ok $node, "App::Services::get_nodes({id => 1}, \$schema) should not return undef";
is $node->{id}, 1, "Master node id should be 1";
is $node->{parent}, undef, "Master node parent should be undef";
is scalar @{$node->{nodes}}, 2, "Master node should have 2 nodes";
is $node->{nodes}->[0]->{id}, 2, "masterNode->nodes[0] id should be 2"; 
is $node->{nodes}->[0]->{parent}, 1, "masterNode->nodes[0] parent should be 1"; 

$node = $app->get_nodes({id => 4}, $schema);
ok $node, "App::Services::get_nodes({id => 4}, \$schema) should not return undef";
is $node->{id}, 4, "node#4 id should be 4";
is $node->{parent}, 2, "node#4 parent should be undef";
is scalar @{$node->{nodes}}, 3, "node#4 should have 3 nodes";

$node = $app->get_nodes({id => 666}, $schema);
ok $node, "get_nodes({id => 666}) should not return undef";
ok $node->{errorMessage}, "get_nodes({id => 666}) errorMessage should be returned";
is $node->{status}, 404, "get_nodes({id => 666}) status 404 for not found is Ok";

#
# get_addNode()
#
$node = App::Services->get_addNode(
  {id => 1},
  $schema);

ok $node, "App::Services::get_addNode({id => 1}, \$schema) should not return undef";
is $node->{parent}, 1, "New node should have 1 as parent";
is $node->{id}, 18, "New node id should be 18";
$node = $app->get_nodes({id => 1}, $schema);
is scalar @{$node->{nodes}}, 3, "Master node should now have 3 nodes";


$node = $app->get_addNode({id => 666}, $schema);
ok $node, "get_addNode({id => 666}) should not return undef";
ok $node->{errorMessage}, "get_addNode({id => 666}) errorMessage should be returned";
is $node->{status}, 404, "get_addNode({id => 666}) status 404 for not found is Ok";

#
# get_delNode()
#
$node = App::Services->get_delNode(
  {id => 16},
  $schema);

ok $node, "App::Services::get_delNode({id => 16}, \$schema) should not return undef";
is $node, 1, "Should return '1'";
$node = App::Services->get_delNode(
  {id => 666},
  $schema);
ok $node, "App::Services::get_delNode({id => 666}, \$schema) should not return undef";
ok $node->{errorMessage}, "get_nodes({id => 666}) errorMessage should be returned";
is $node->{status}, 404, "get_nodes({id => 666}) status 404 for not found is Ok";

done_testing();

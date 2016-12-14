package App::Services; {
  use warnings;
  use strict;
  use utf8;
  use autodie;

  sub get_nodes {
    my ($self, $p, $schema, $parent) = @_;

    my $id = $p->{id};

    if( not defined $parent ) {
      ($id, $parent) = $self->findNode($id, $schema);
    }

    my $node = {
      id => $id,
      parent => $parent,
    };

    my $rs = $schema->resultset('Node')->search({ 'me.parent' => $id });

    my $nodes = [];

    while (my $node = $rs->next) {
      my ($parent);

      if(defined $node) {
        $id = $node->id;
      }
      if(defined $node->parent) {
        $parent = $node->parent->id;
      }

      if($id) {
        my $node = $self->get_nodes({id => $id}, $schema, $parent);
        push @$nodes, $node;
      }
    }
    $node->{nodes} = scalar @$nodes ? $nodes : undef;

    if(not defined $node->{id}) {
      return { errorMessage => "No such node ID: $p->{id}", status => 404 };
    }

    $node;
  }

  sub get_addNode {
    my ($self, $p, $schema) = @_;

    my ($id, $parent) = $self->findNode($p->{id}, $schema);

    if(not defined $id) {
      return { errorMessage => "No such parent ID: $p->{id}", status => 404 };
    }

    my $res = $schema->resultset('Node')->create({
        parent => $p->{id},
      });

    my %hash =  $res->get_columns;
    return \%hash;
  }

  sub get_delNode {
    my ($self, $p, $schema) = @_;

    my $res = $schema->resultset('Node')->search({ id => $p->{id}, });

    $res = $res->delete();

    if($res ne '1') {
      return { errorMessage => "Could not delete: No such ID: $p->{id}", status => 404 };
    }

    return $res;

  }


  sub findNode {
    my ($self, $id, $schema, $parent) = @_;
    my $rs = $schema->resultset('Node')->search( { 'me.id' => $id });
    while (my $node = $rs->next) {
      $parent = defined $node->parent ? $node->parent->id : undef;
      return $id, $parent;
    }
  }

  1;
}

=pod
=head1 NAME
App::Services - web services for the Tree Node applicaton

=head2 How it works
This module is called by app.pl perl script. Subs prefixed with "get_" are for GET requests. 

=item get_nodes()
$self - ourself.
$p - a hash of parameters from GUI. For GET requests taken from browser string (please refer to app.pl). $p->{id} used as to find a node in DB.
$schema - schema, provided by app.pl or test engine. It is App::Schema, subclass of DBIx::Class::Schema
$parent - INT, provided if called from the code to avoid extra calls to DB while generating complete node tree.

Returns error message with status 404 (caught by App::JSon) in case if id not found in DB. GUI checks so $id is positive and is a number.
If node found returns the complete hash of node and all sub nodes.

=item get_addNode()
$self - the class.
$p - a hash of parameters from GUI. For GET requests taken from browser string (please refer to app.pl). $p->{id} used as parent node id.
$schema - schema, provided by app.pl or test engine. It is App::Schema, subclass of DBIx::Class::Schema

First checks if such node exists findNode($id); If it does then adds the node and returns it.

=item get_addNode()
$self - the class.
$p - a hash of parameters from GUI. For GET requests taken from browser string (please refer to app.pl). $p->{id} used as node id.
$schema - schema, provided by app.pl or test engine. It is App::Schema, subclass of DBIx::Class::Schema

If delete command did did not return "1" then trow error. Since SQL table "nodes" property "parent" has "ON DELETE CASCADE" we can delete a node that has got "children".

=item findNode()
$self - ourself.
$p - a hash of parameters from GUI. For GET requests taken from browser string (please refer to app.pl). $p->{id} used as to find a node in DB.
$schema - schema, provided by app.pl or test engine. It is App::Schema, subclass of DBIx::Class::Schema
$parent - INT, provided if called from the code to avoid extra calls to DB while generating complete node tree.

If node with $p->{id} is found in DB then return it, undef otherwise.

=head2 Testing
Module is tested by ../../t/App/Services.t, run from root folder for the project.

=cut

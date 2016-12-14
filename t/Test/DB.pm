package Test::DB;

use DBIx::Mint;
use DBI;
use v5.10;

sub connection_params{
  return ( 'dbi:SQLite:dbname=t/app.db', '', '',
    { AutoCommit => 1, RaiseError => 1 });
}

sub remove_db {
  if (-e 't/app.db') {
    unlink 't/app.db';
  }
}

sub init {
  my $dbh = shift;
  local $/ = ';';
  while (<DATA>) {
    next if /^\s*$/;
    s/^\s+|;|\s+$//g;
    $dbh->do($_);
  }
}

sub init_db {
  remove_db();
  my $dbh  = DBI->connect( connection_params() );
  init($dbh);
  return $dbh;
}

sub connect_db {
  remove_db();
  my $mint = DBIx::Mint->connect( connection_params() );
  init($mint->dbh);
  return $mint;
}

1;

#
__DATA__
CREATE TABLE nodes (
  id        INTEGER NOT NULL PRIMARY KEY,
  parent    INTEGER
);

INSERT INTO nodes(id) values(1);
INSERT INTO nodes(parent) values(1);
INSERT INTO nodes(parent) values(1);

INSERT INTO nodes(parent) values(2);
INSERT INTO nodes(parent) values(2);

INSERT INTO nodes(parent) values(3);
INSERT INTO nodes(parent) values(3);
INSERT INTO nodes(parent) values(3);

INSERT INTO nodes(parent) values(4);
INSERT INTO nodes(parent) values(4);
INSERT INTO nodes(parent) values(4);

INSERT INTO nodes(parent) values(9);
INSERT INTO nodes(parent) values(9);
INSERT INTO nodes(parent) values(9);

INSERT INTO nodes(parent) values(12);
INSERT INTO nodes(parent) values(12);
INSERT INTO nodes(parent) values(12);

DROP TABLE IF EXISTS nodes;

CREATE TABLE nodes (
  id        INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  parent    INTEGER
);

ALTER TABLE nodes ADD FOREIGN KEY (parent) REFERENCES nodes(id) ON DELETE CASCADE;

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

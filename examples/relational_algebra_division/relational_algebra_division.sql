CREATE SCHEMA rad; -- Relational Algebra Division
SET SCHEMA 'rad';

-- Table creation
CREATE TABLE supplier (
  sid serial not null,
  name varchar );

CREATE TABLE part (
  pid serial not null,
  name varchar );

CREATE TABLE catalog (
  sid integer not null,
  pid integer not null );

-- Data insertion
INSERT INTO supplier (name) values
  ('Dath Vader'),
  ('Han Solo'),
  ('R2D2');

INSERT INTO part (name) VALUES
  ('Light Sable'),
  ('Laser Gun');

INSERT INTO catalog (sid, pid) values
  (1,1),(1,2),
  (2,1),(2,2),
  (3,1),(3,3); -- Part ID = 3 does not exists.

-- Queries
SELECT * FROM supplier s FULL OUTER JOIN catalog USING (sid)
                         FULL OUTER JOIN part USING (pid);

--
SELECT * FROM Catalog C
WHERE NOT EXISTS (SELECT P.pid FROM Part P
                  WHERE NOT EXISTS (SELECT C1.sid FROM Catalog C1
                                    WHERE C1.sid = C.sid
                                    AND C1.pid = P.pid) );

-- Suppliers for which doesn't exists any part that they doesn't provide.
SELECT * FROM supplier S
WHERE NOT EXISTS ( SELECT * FROM part P
                   WHERE NOT EXISTS ( SELECT * FROM catalog C
                                      WHERE S.sid = C.sid
                                        AND P.pid = C.pid ) );

-- To better understand the above query.
-- The Non exitence of a product related to RD2D is the reason why the tupple is excleded at the final query.
SELECT * FROM part P
WHERE NOT EXISTS ( SELECT * FROM catalog C
                   WHERE P.pid = C.pid
                     AND C.sid = 3); -- R2D2 Here!


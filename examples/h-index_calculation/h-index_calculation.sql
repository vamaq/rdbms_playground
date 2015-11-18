-- Table creation:

create table scientist (
  id integer primary key, -- Alias to ROWID SQLite
  name varchar );

create table paper (
  id integer primary key,
  scientist_id integer not null,
  title varchar );

create table citation (
  id integer primary key,
  paper_id integer not null,
  citation_details varchar ); -- not used

-- Data insertion

insert into scientist (name) values
  ('Mr Doom'),
  ('Batman'),
  ('Superman');

insert into paper (scientist_id, title) values
  (1,'Doomsday'), -- 12 citations
  (1,'Bad Day'), -- 11 citations
  (1,'Sad Day'), -- 10 citations
  (1,'Programming Day'), -- 5 citations
  (1,'Debugin bug #! Error'), -- 2 citations
  (1,'Happy Coding'), -- 0 citations
  (2,'I have money'), -- 1 citations
  (3,'I have no planet'); -- 0 citations (it's not very popular)


insert into citation (paper_id) values
  (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
  (2),(2),(2),(2),(2),(2),(2),(2),(2),(2),(2),
  (3),(3),(3),(3),(3),(3),(3),(3),(3),(3),
  (4),(4),(4),(4),(4),
  (5),(5),
  (7);

-- Query

with aux as ( -- Amount of citations
  select p.id, p.scientist_id, p.title, count(*) as citations
  from paper p join citation c2 on (p.id = c2.paper_id)
  group by 1,2,3 )
select id, name, min(h) as h_index from (
  select c.id,
         c.name,
         aux1.title,
         aux1.citations,
         -- Replacing the use of analytical functions
         -- Eq. to: count(*) over (parition by c.id order by p.citations desc)
         ( select count(*) from aux aux2
           where aux2.citations >= aux1.citations
             and aux2.scientist_id = aux1.scientist_id) as h
  from scientist c join aux aux1 on (c.id = aux1.scientist_id)
) where h >= citations
group by id, name;


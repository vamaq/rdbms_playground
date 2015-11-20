CREATE SCHEMA ppac; -- Posgis Poygon Angle Calculation

CREATE EXTENSION postgis SCHEMA ppac;
CREATE EXTENSION postgis_topology SCHEMA ppac;

SET SCHEMA 'ppac';

SELECT postgis_full_version();
-- POSTGIS="2.1.8 r13780" GEOS="3.4.2-CAPI-1.8.2 r3921" PROJ="Rel. 4.8.0, 6 March 2012" GDAL="GDAL 1.10.1,
-- released 2013/08/26" LIBXML="2.9.1" LIBJSON="UNKNOWN" RASTER

create table poly_and_multipoly (
  id serial not null primary key,
  name char(1) not null,
  the_geom geometry not null
);

-- add data, A is a polygon, B is a multipolygon
insert into poly_and_multipoly (name, the_geom) values
  ('A','POLYGON((7.7 3.8,7.7 5.8,9.0 5.8,7.7 3.8))'::geometry),
  ('B','MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ((-1 -1,-1 -2,-2 -2,-2 -1,-1 -1)))'::geometry);

select id, name, ST_AsText(the_geom) from poly_and_multipoly;


-- 1.- Extract the individual linestrings and the Polygon number for later identification
select id,
       name,
       ST_AsText((ST_Dump(ST_Boundary(the_geom))).geom) as line,
       (ST_Dump(ST_Boundary(the_geom))).path -- To identify the polygon
from poly_and_multipoly;


-- 2.- extract the endpoints for every 2-point line segment for each linestring
-- Group polygons from multipolygon
select id,
       name,
       coalesce(path[1],0) as polygon_num,
       generate_series(1, ST_Npoints(geom)-1) as point_order,
       ST_AsText(ST_Pointn(geom, generate_series(1, ST_Npoints(geom)-1))) as sp,
       ST_AsText(ST_Pointn(geom, generate_series(2, ST_Npoints(geom)  ))) as ep
from ( -- 1.- Extract the individual linestrings and the Polygon number for later identification
       select id,
              name,
              (ST_Dump(ST_Boundary(the_geom))).geom as geom,
              (ST_Dump(ST_Boundary(the_geom))).path as path-- To identify the polygon
        from poly_and_multipoly ) as pointlist
order by path;


-- 3.- Create segments from points and calculate azimuth for each line.
--     two calls of generate_series for a single function wont work (azimuth).
select id,
       name,
       polygon_num,
       point_order as line_order,
       ST_Astext(ST_Makeline(sp,ep)) as line,
       degrees(ST_Azimuth(sp,ep)) as azimuth
from (-- 2.- extract the endpoints for every 2-point line segment for each linestring
      --     Group polygons from multipolygon
      select id,
             name,
             coalesce(path[1],0) as polygon_num,
             generate_series(1, ST_Npoints(geom)-1) as point_order,
             ST_Pointn(geom, generate_series(1, ST_Npoints(geom)-1)) as sp,
             ST_Pointn(geom, generate_series(2, ST_Npoints(geom)  )) as ep
      from ( -- 1.- Extract the individual linestrings and the Polygon number for later identification
             select id,
                    name,
                    (ST_Dump(ST_Boundary(the_geom))).geom as geom,
                    (ST_Dump(ST_Boundary(the_geom))).path as path -- To identify the polygon
              from poly_and_multipoly ) as pointlist ) as segments;

-- 3.- Create segments from points and calculate azimuth for each line.
--     two calls of generate_series for a single function wont work (azimuth).
select id,
       name,
       polygon_num,
       point_order as vertex,
       --
       case when point_order = 1
         then last_value(ST_Astext(ST_Makeline(sp,ep))) over (partition by id, polygon_num)
         else lag(ST_Astext(ST_Makeline(sp,ep)),1) over (partition by id, polygon_num order by point_order)
       end ||' - '||ST_Astext(ST_Makeline(sp,ep)) as lines,
       --
       abs(abs(
       case when point_order = 1
         then last_value(degrees(ST_Azimuth(sp,ep))) over (partition by id, polygon_num)
         else lag(degrees(ST_Azimuth(sp,ep)),1) over (partition by id, polygon_num order by point_order)
       end - degrees(ST_Azimuth(sp,ep))) -180 ) as ang
from (-- 2.- extract the endpoints for every 2-point line segment for each linestring
      --     Group polygons from multipolygon
      select id,
             name,
             coalesce(path[1],0) as polygon_num,
             generate_series(1, ST_Npoints(geom)-1) as point_order,
             ST_Pointn(geom, generate_series(1, ST_Npoints(geom)-1)) as sp,
             ST_Pointn(geom, generate_series(2, ST_Npoints(geom)  )) as ep
      from ( -- 1.- Extract the individual linestrings and the Polygon number for later identification
             select id,
                    name,
                    (ST_Dump(ST_Boundary(the_geom))).geom as geom,
                    (ST_Dump(ST_Boundary(the_geom))).path as path -- To identify the polygon
              from poly_and_multipoly ) as pointlist ) as segments;

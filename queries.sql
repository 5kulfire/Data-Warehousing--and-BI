CREATE table MyDimDate (
	dateid integer NOT NULL,
	month smallint NOT NULL,
	monthname VARCHAR(9) NOT NULL,
	day smallint NOT NULL,
	weekdaynum smallint NOT NULL,
	weekdayname VARCHAR(7),
	year int NOT NULL,
	PRIMARY KEY (dateid)
);

CREATE table MyDimWaste (
	wasteid integer NOT NULL,
	waste_type VARCHAR(11) NOT NULL,
	PRIMARY KEY (wasteid)
);


CREATE table MyDimZone (
	zone_id integer NOT NULL,
	zone VARCHAR(6) NOT NULL,
	city VARCHAR(16) NOT NULL,
	PRIMARY KEY (zone_id)
);

CREATE table MyFactTrips (
	trip_number integer NOT NULL,
	dateid integer NOT NULL,
	zone_id integer NOT NULL,
	wasteid integer NOT NULL,
	waste_collected decimal NOT NULL,
	PRIMARY KEY (trip_number),
	FOREIGN KEY (dateid) REFERENCES MYDIMDATE(dateid),
	FOREIGN KEY (wasteid) REFERENCES MYDIMWASTE(wasteid),
	FOREIGN KEY (zone_id) REFERENCES MYDIMZONE(zone_id)
);

SELECT f.stationid, t.trucktype, sum(f.wastecollected) as TotalWasteCollected
FROM facttrips f 
LEFT JOIN dimtruck t 
ON f.truckid = t.truckid
GROUP BY
GROUPING SETS(f.stationid, t.trucktype)
ORDER BY f.stationid, t.trucktype;

SELECT d.year, s.city, f.stationid, sum(f.wastecollected) as totalwastecollected
FROM facttrips f
LEFT JOIN dimdate d
ON f.dateid= d.dateid
LEFT JOIN dimstation s 
ON f.stationid= s.stationid
GROUP BY ROLLUP (d.year, s.city, f.stationid)
ORDER BY d.year, s.city;

SELECT d.year, s.city, f.stationid, avg(f.wastecollected) as AvgWasteCollected
FROM facttrips f
LEFT JOIN dimdate d
ON f.dateid= d.dateid
LEFT JOIN dimstation s 
ON f.stationid= s.stationid
GROUP BY CUBE (d.year, s.city, f.stationid)
ORDER BY d.year, s.city;

CREATE TABLE max_waste_stats (city, stationid, trucktype, maxwastecollected) AS
(SELECT s.city, f.stationid, t.trucktype, max(f.wastecollected)
FROM facttrips f 
LEFT JOIN dimstation s 
ON f.stationid= s.stationid
LEFT JOIN dimtruck t 
ON f.truckid= t.truckid
GROUP BY s.city, t.trucktype, f.stationid)
	DATA INITIALLY DEFERRED
	REFRESH DEFERRED
	MAINTAINED BY SYSTEM;

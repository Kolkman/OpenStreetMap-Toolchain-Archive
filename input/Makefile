
# Makefile to turn input into something..
# See https://wiki.openstreetmap.org/wiki/Daily_update_an_OSM_XML_file

WORKDIR_OSM=./osmosis-work

INPUT= netherlands-latest.o5m germany-latest.o5m belgium-latest.o5m france-latest.o5m denmark-latest.o5m
TEMPFILE := $(shell mktemp ./updated.o5m.XXXX)
FETCH?= /usr/bin/curl -O

.SUFFIXES: .o5m .pbf


# OSMOSIS is installed with BREW




all: updated.o5m uithoorn.o5m MyMAP.o5m


update:
	osmosis -v --read-replication-interval workingDirectory=${WORKDIR_OSM} --simplify-change --write-xml-change changes.osc.gz
	gunzip changes.osc.gz




changes.osc:
	osmosis -v --read-replication-interval workingDirectory=${WORKDIR_OSM} --simplify-change --write-xml-change changes.osc.gz
	gunzip changes.osc.gz

# Note that technically updated should exist. This should only be triggered by the changes
updated.o5m: combined.o5m changes.osc
	../bin/osmconvert $@ --out-o5m changes.osc > ${TEMPFILE}
	mv ${TEMPFILE} $@




MyMAP.o5m: updated.o5m MyMAP.poly
	../bin/osmconvert   updated.o5m  -B=MyMAP.poly  --out-o5m > $@

WEST-NEDERLAND.o5m: updated.o5m WEST-NEDERLAND.poly
	../bin/osmconvert   updated.o5m  -B=WEST-NEDERLAND.poly  --out-o5m > $@

uithoorn.o5m: updated.o5m  uithoorn_noord-holland.poly
	../bin/osmconvert   updated.o5m  -B=uithoorn_noord-holland.poly  --out-o5m > $@

%.o5m: %.osm.pbf
	../bin/osmconvert $< -o=$@ 

combined.o5m: ${INPUT} 
	../bin/osmconvert $^ -o=$@
	link $@ updated.o5m 

netherlands-latest.osm.pbf:
	echo "BLA $@--"
	${FETCH} http://download.geofabrik.de/europe/$@

france-latest.osm.pbf:
	${FETCH} http://download.geofabrik.de/europe/$@

belgium-latest.osm.pbf:
	${FETCH} http://download.geofabrik.de/europe/$@

germany-latest.osm.pbf:
	${FETCH} http://ftp5.gwdg.de/pub/misc/openstreetmap/download.geofabrik.de/$@


denmark-latest.osm.pbf:
	${FETCH} http://download.geofabrik.de/europe/$@


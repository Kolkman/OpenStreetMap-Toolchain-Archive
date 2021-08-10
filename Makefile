# Makefile for mkgmap toolchain.


INPUT?=		updated.o5m
#INPUT?=		uithoorn.o5m
#INPUT?=		MyMAP.o5m
#INPUT?=		WEST-NEDERLAND.o5m

# styles copied from mkgmap-style-sheets (update with git).

STYLE?=		styles/kloot-garmin

#TYP?=		2000.txt
#TYP?=		mapnik2.txt
#ID?=        	2000

#TYP?=		kloot.txt
#ID?=        	1966

TYP?=		kloot2.txt
ID?=        	1966


#TYP?=		CFMaster.txt
#ID?= 		1500


PAD?=		00000000
MAPID?=		${shell echo ${ID}${PAD} | cut -c1-8}

#OSMOSIS with brew
OSMOSIS?=	/usr/local/bin/osmosis
OSMCONVERT?=	bin/osmconvert
# OSMFILTER with brew
OSMFILTER?=	/usr/local/bin/osmfilter
FETCH?= /usr/bin/curl -O



MKGMAPJAR?=  bin/mkgmap/mkgmap.jar
SPLITTERJAR?= bin/splitter/splitter.jar

SPLITTER?=	java -Xmx8000m -jar ${SPLITTERJAR}
MKGMAP?=	java -Xmx8000m -jar ${MKGMAPJAR}






all: bounds split gmapsupp.img





createinput: pullmaps
	osmconvert north_america.osm south_america.osm -o=americas.osm






work/boundaries.o5m: input/${INPUT}
	mkdir -p work
	${OSMFILTER} $? --keep-nodes= \
	--keep-ways-relations="boundary=administrative  =postal_code" \
	--out-o5m > $@


bounds: work/boundaries.o5m
	java -cp ${MKGMAPJAR} \
		uk.me.parabola.mkgmap.reader.osm.boundary.BoundaryPreprocessor \
		$? \
		$@
	touch bounds


sea.zip:
	${FETCH} http://osm.thkukuk.de/data/sea-latest.zip && move sea-latest.zip sea.zip

#bounds:
#	${FETCH} http://osm2.pleiades.uni-wuppertal.de/bounds/latest/bounds.bzip2
#	bunzip2 bounds.bizip2



split: splitted/template.args


splitted/template.args: input/${INPUT}
	mkdir -p logs
	${SPLITTER} \
		--overlap=0 \
		--max-nodes=1000000 \
		--no-trim \
		--output=pbf \
		--output-dir=splitted \
		--mapid=${MAPID} \
		input/${INPUT} > logs/splitter-log

gmapsupp.img: output/gmapsupp.img 
	- rm $@
	ln -s $? $@



Basecamptest.dmg:
	hdiutil create $@ -volname "BCamp_test" -size 4g -format  UDRW  -fs ExFAT -srcfolder ./BaseCamp-Source


basecamp: gmapsupp.img 
	sh ./basecamp-copy.sh 



output/gmapsupp.img: ${STYLE}/${TYP} ${STYLE}/info ${STYLE}/lines ${STYLE}/options ${STYLE}/points ${STYLE}/polygons ${STYLE}/relations ${STYLE}/version optionsfile.args splitted/template.args bounds input/${INPUT}
	mkdir -p output
	${MKGMAP} \
		--output-dir=output \
		--description="Kloot Industries Map" \
		--family-name="Kloot  `date '+%Y-%m-%d'`" \
		--series-name="Kloot MAP `date '+%Y-%m-%d'`" \
		--overview-mapname="Kloot_Industries" \
		--area-name="OSM `date "+%Y-%m-%d"`" \
		--family-id=${ID} \
		--read-config=optionsfile.args \
		--style-file=./${STYLE} \
		-c splitted/template.args ${STYLE}/${TYP}


update:
	cd input && ${MAKE} update


input/${INPUT}: input/changes.osc
	cd input && make ${INPUT}



clean:
	rm -rf bounds splitted logs output work sea.zip

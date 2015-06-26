# Version: 0.0.1
FROM ubuntu:latest

MAINTAINER Juan Pedro Perez "jp.alcantara@geographica.gs"

# Environment
ENV POSTGRES_PASSWD postgres
ENV ROOTDIR /usr/local

WORKDIR $ROOTDIR

ADD packages/proj4-patch/src/pj_datums.c $ROOTDIR/
ADD packages/proj4-datumgrid-1.5.tar.bz2 $ROOTDIR
ADD packages/proj4-patch/nad/epsg $ROOTDIR/
ADD packages/proj4-patch/nad/PENR2009.gsb $ROOTDIR/
ADD packages/postgis-1.5.8-patch/spatial_ref_sys.sql $ROOTDIR/
ADD http://download.osgeo.org/postgis/source/postgis-1.5.8.tar.gz $ROOTDIR/
ADD https://ftp.postgresql.org/pub/source/v9.1.2/postgresql-9.1.2.tar.bz2  $ROOTDIR/
ADD http://download.osgeo.org/geos/geos-3.4.2.tar.bz2 $ROOTDIR/
ADD http://download.osgeo.org/proj/proj-4.8.0.tar.gz $ROOTDIR/


# Build and configure PostgreSQL 9.1.2, GEOS 3.4.2, Proj 4.8.0, and PostGIS 1.5.8
RUN apt-get update && apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev  && tar xvjf postgresql-9.1.2.tar.bz2 && tar vxzf postgis-1.5.8.tar.gz && tar xvjf geos-3.4.2.tar.bz2 && tar xvzf proj-4.8.0.tar.gz && cd postgresql-9.1.2 ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib CC='gcc-4.7 -m64' ; cd .. && cd postgresql-9.1.2 ; make ; cd .. && cd postgresql-9.1.2 ; make install ; cd .. && cd postgresql-9.1.2/contrib ; make all ; cd ../.. && cd postgresql-9.1.2/contrib ; make install ; cd ../.. && groupadd postgres && useradd -r postgres -g postgres && echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e && cd geos-3.4.2 ; ./configure ; cd .. && cd geos-3.4.2 ; make ; cd .. && cd geos-3.4.2 ; make install ; cd .. && mv ${ROOTDIR}/proj4-datumgrid-1.5/* ${ROOTDIR}/proj-4.8.0/nad && mv ${ROOTDIR}/pj_datums.c ${ROOTDIR}/proj-4.8.0/src && mv ${ROOTDIR}/epsg ${ROOTDIR}/proj-4.8.0/nad/ && mv ${ROOTDIR}/PENR2009.gsb ${ROOTDIR}/proj-4.8.0/nad/ && chown -R 142957:5000 ${ROOTDIR}/proj-4.8.0 && cd ${ROOTDIR}/proj-4.8.0 ; ./configure CC='gcc-4.7 -m64' ; cd .. && cd ${ROOTDIR}/proj-4.8.0 ; make ; cd .. && cd ${ROOTDIR}/proj-4.8.0 ; make install ; cd .. && ldconfig && mv ${ROOTDIR}/spatial_ref_sys.sql ${ROOTDIR}/postgis-1.5.8/ && cd postgis-1.5.8 && ./configure CC='gcc-4.7 -m64' && cd .. && cd postgis-1.5.8 && make && cd .. && cd postgis-1.5.8 && make install && cd .. && locale-gen en_US.UTF-8 && locale-gen es_ES.UTF-8 && rm -Rf postgresql-9.1.2 && rm -Rf postgis-1.5.8 && rm -Rf proj-4.8.0 && rm -Rf proj4-datumgrid-1.5 && rm -Rf geos-3.4.2

EXPOSE 5432
CMD su postgres -c 'postgres -D /data'
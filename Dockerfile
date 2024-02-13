FROM python:2.7

ENV MOINMOIN_VERSION 1.9.11

# Add user and group for MoinMoin
RUN groupadd -r moin && useradd -r -g moin moin

# Install MoinMoin
RUN set -ex \
	&& pip install --no-cache-dir "moin==$MOINMOIN_VERSION" \
	&& mkdir -p /usr/local/moin \
	&& chown -R moin:moin /usr/local/moin

RUN set -ex \
	&& mkdir -p /usr/local/moin/server \
	&& cp -r /usr/local/share/moin/server/* /usr/local/moin/server/ \
	&& sed -i "/^#sys.path.insert(0, '\/path\/to\/farmconfigdir')/a sys.path.insert(0, '\/usr\/local\/moin\/config')" /usr/local/moin/server/moin.* \
	&& sed -i "s/^#from MoinMoin import log/from MoinMoin import log/" /usr/local/moin/server/moin.* \
	&& sed -i "s/^#log.load_config('\/path\/to\/logging_configuration_file')/log.load_config('\/usr\/local\/moin\/config\/logging\/logfile')/" /usr/local/moin/server/moin.* \
	&& mkdir -p /usr/local/moin/log

ENV PATH /usr/local/moin/server:$PATH

# Install uWSGI
RUN set -ex \
	&& pip install --no-cache-dir uwsgi

COPY moin/uwsgi.ini /usr/local/moin/

# Copy docker-entrypoint.sh
COPY docker-entrypoint.sh /

# Define ports, volumes and the entrypoint
EXPOSE 8080
EXPOSE 3031
EXPOSE 9191

VOLUME /usr/local/moin/config
VOLUME /usr/local/moin/data
VOLUME /usr/local/moin/underlay
VOLUME /usr/local/moin/log

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/uwsgi", "/usr/local/moin/uwsgi.ini"]

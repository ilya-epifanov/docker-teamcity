FROM debian:sid

MAINTAINER Ilya Epifanov <elijah.epifanov@gmail.com>

RUN apt-get update \
 && apt-get install -y curl ca-certificates --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)" \
 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture).asc" \
 && gpg --verify /usr/local/bin/gosu.asc \
 && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu

RUN groupadd -r teamcity \
 && useradd -r -d /var/lib/teamcity -m -g teamcity teamcity

RUN apt-get update \
 && apt-get install -y openjdk-8-jre-headless --no-install-recommends \
 && dpkg-reconfigure ca-certificates-java \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV TEAMCITY_VERSION=9.1.1

RUN curl -o /tmp/teamcity.tar.gz -SL "http://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz" \
 && tar xf /tmp/teamcity.tar.gz --strip-components 1 -C /var/lib/teamcity \
 && rm /tmp/teamcity.tar.gz \
 && mkdir -p /var/lib/teamcity/data-lib/lib/jdbc /var/lib/teamcity/logs \
 && curl -o /var/lib/teamcity/data-lib/lib/jdbc/postgresql.jar -SL "https://jdbc.postgresql.org/download/postgresql-9.4-1200.jdbc41.jar" \
 && chown -R teamcity /var/lib/teamcity

VOLUME /var/lib/teamcity/conf /var/lib/teamcity/logs

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV TEAMCITY_DATA_PATH="/var/lib/teamcity/data"
ENV TEAMCITY_SERVER_OPTS=""
ENV TEAMCITY_SERVER_MEM_OPTS="-mx1g -XX:+UseG1GC"

EXPOSE 8111
CMD ["/var/lib/teamcity/bin/teamcity-server.sh", "run"]

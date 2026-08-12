# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 debian:12-slim AS build

ARG BYOND_VERSION=516.1686
ARG BYOND_SHA256=8f47f4a281bb7372ba2654af5ace1eb11cbca56b5e2e3cf3fb61ecbfe530a860

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		unzip \
		libc6:i386 \
		libstdc++6:i386 \
		libgcc-s1:i386 \
		libcurl4:i386 \
	&& curl -fsSLo /tmp/byond.zip \
		"https://www.byond.com/download/build/516/${BYOND_VERSION}_byond_linux.zip" \
	&& echo "${BYOND_SHA256}  /tmp/byond.zip" | sha256sum -c - \
	&& unzip -q /tmp/byond.zip -d /opt \
	&& chmod 0755 /opt/byond/bin/DreamDaemon /opt/byond/bin/DreamMaker \
	&& rm -rf /var/lib/apt/lists/* /tmp/byond.zip

ENV BYOND_SYSTEM=/opt/byond \
	LD_LIBRARY_PATH=/opt/byond/bin

WORKDIR /src

COPY DU.dme UI.dmf SECRETS.dm ./
COPY src ./src

# Never let Dream Maker reuse an artifact supplied by the host. The DMB and
# resource cache must always be produced together by this exact compilation.
RUN rm -f DU.dmb DU.rsc DU.dyn.rsc DU.dyn.rsc.lk DU.rsc.lk \
	&& /opt/byond/bin/DreamMaker DU.dme \
	&& test -s DU.dmb \
	&& test -s DU.rsc

FROM --platform=linux/amd64 debian:12-slim

RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		libc6:i386 \
		libstdc++6:i386 \
		libgcc-s1:i386 \
		libcurl4:i386 \
		python3 \
	&& rm -rf /var/lib/apt/lists/* \
	&& groupadd --gid 10001 nexus \
	&& useradd --uid 10001 --gid nexus \
		--home-dir /srv/nexus --no-create-home \
		--shell /usr/sbin/nologin nexus \
	&& install -d -o nexus -g nexus -m 0700 /srv/nexus \
	&& install -d -o root -g root -m 0755 /opt/nexus

COPY --from=build /opt/byond /opt/byond
COPY --from=build --chown=root:root /src/DU.dmb /src/DU.rsc /opt/nexus/
COPY --chown=root:root deploy/docker/entrypoint.sh /usr/local/bin/nexus-entrypoint
COPY --chown=root:root deploy/docker/profile_media_inspector.py /opt/nexus/profile_media_inspector.py

RUN chmod 0444 /opt/nexus/DU.dmb /opt/nexus/DU.rsc \
	&& chmod 0555 /usr/local/bin/nexus-entrypoint /opt/nexus/profile_media_inspector.py \
	&& python3 /opt/nexus/profile_media_inspector.py --self-test

ENV BYOND_SYSTEM=/opt/byond \
	LD_LIBRARY_PATH=/opt/byond/bin \
	HOME=/srv/nexus \
	NEXUS_RUNTIME_DIR=/srv/nexus \
	PYTHONDONTWRITEBYTECODE=1

USER nexus
WORKDIR /srv/nexus

EXPOSE 50000/tcp

ENTRYPOINT ["/usr/local/bin/nexus-entrypoint"]
CMD ["50000", "-safe", "-home", "/srv/nexus", "-cd", "/srv/nexus", "-params", "nexus_environment=playtest&nexus_playtest_rewards=1"]

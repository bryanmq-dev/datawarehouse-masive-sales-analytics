FROM postgres:15

RUN apt-get update && apt-get install -y --no-install-recommends \

    ca-certificates \

    postgresql-15-tds-fdw \

    postgresql-15-cron \

    git \

    make \

    gcc \

    postgresql-server-dev-15 \

    libsqlite3-dev \

    && rm -rf /var/lib/apt/lists/*


# Descargamos y compilamos sqlite_fdw con los certificados ya validados

RUN git clone https://github.com/pgspider/sqlite_fdw.git /tmp/sqlite_fdw \

    && cd /tmp/sqlite_fdw \

    && make USE_PGXS=1 \

    && make USE_PGXS=1 install \

    && rm -rf /tmp/sqlite_fdw 

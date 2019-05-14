FROM elixir

RUN apt-get update && \
  apt-get install -y postgresql-client

RUN mkdir /app
COPY . ./app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN mix do compile

ENV PGHOST=localhost
ENV PGPORT=5432
ENV PGUSER=postgres

CMD [ "/app/entrypoint.sh" ]

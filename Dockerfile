FROM elixir

RUN apt-get update && \
  apt-get install -y postgresql-client



# install NodeJS and NPM
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install nodejs
RUN apt-get install -y inotify-tools




RUN mkdir /app
COPY . ./app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix do compile

RUN cd assets && npm install && npm run deploy && cd ../ && mix phx.digest

# RUN cd assets && webpack --mode production && cd ..

CMD [ "/app/entrypoint.sh" ]

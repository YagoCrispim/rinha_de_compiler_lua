FROM nickblah/lua

WORKDIR /app

COPY . /app

CMD lua src/main.lua

FROM node:20-slim AS base
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN npm ci --omit=dev

FROM base AS build

# We need to install lua to build the client
RUN apt-get update && apt-get install -y lua5.3

RUN npm ci
RUN npm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/_site /app/_site
COPY --from=build /app/_bin /app/_bin

ENV NODE_ENV=production
EXPOSE 8080
CMD [ "node", "/app/_bin/server.cjs" ]

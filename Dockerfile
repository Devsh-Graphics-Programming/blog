# syntax=docker/dockerfile:1

FROM node:20-alpine AS build
WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1

RUN apk add --no-cache libc6-compat

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG BLOG_BASEURL=/
ENV BLOG_BASEURL=${BLOG_BASEURL}

RUN npm run build

FROM caddy:2.9-alpine AS runner
WORKDIR /srv/blog

RUN addgroup -S caddy && adduser -S caddy -G caddy
COPY --from=build --chown=caddy:caddy /app/build ./
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 3000
USER caddy
ENTRYPOINT ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]

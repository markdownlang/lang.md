ARG NODE_VERSION=24.7.0
ARG PNPM_VERSION=10.8.0

FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /app

# By copying only the package.json and package-lock.json here, we ensure that the following `-deps` steps are independent of the source code.
# Therefore, the `-deps` steps will be skipped if only the source code changes.
COPY package.json pnpm-lock.yaml ./

RUN --mount=type=cache,target=/root/.npm \
    npm install -g pnpm@${PNPM_VERSION}

FROM base AS prod-deps
RUN pnpm install --prod --frozen-lockfile

FROM base AS build-deps
RUN pnpm install --frozen-lockfile

FROM build-deps AS build
COPY . .
RUN pnpm run build

FROM base AS runtime
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
CMD ["node", "./dist/server/entry.mjs"]

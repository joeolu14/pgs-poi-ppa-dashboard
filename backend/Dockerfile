##################### Deps Stage #####################
FROM artifactory.pfizer.com/mxs/node:16-alpine AS deps

WORKDIR /app
# Install Dependencies
COPY package.json yarn.lock /app/
RUN apk add --no-cache libc6-compat && \
    yarn install --production --ignore-scripts --prefer-offline --frozen-lockfile --network-concurrency 1

##################### Build Stage #####################
FROM artifactory.pfizer.com/mxs/node:16-alpine AS builder

WORKDIR /app
# Install Dependencies
COPY package.json yarn.lock /app/
RUN apk add --no-cache libc6-compat && \
    yarn install --prefer-offline --frozen-lockfile --network-concurrency 1

# Make sure we have enough memory during build
ENV NODE_OPTIONS "--max-old-space-size=2048"
# Copy source code, and build the application
COPY . /app/
RUN yarn build

################## Production Stage ###################
FROM artifactory.pfizer.com/mxs/node:16-alpine

# Import Pfizer Root Certificates
RUN apk update && apk add openssl ca-certificates curl
RUN curl http://pki.pfizer.com/PBACA-G2.crt | openssl x509 -inform der -out /usr/local/share/ca-certificates/PBACA-G2.crt \
    && curl http://pki.pfizer.com/rootca-G2.crt > /usr/local/share/ca-certificates/rootca-G2.crt \
    && curl http://pki.pfizer.com/testrootca-G2.crt > /usr/local/share/ca-certificates/testrootca-G2.crt \
    && update-ca-certificates || true

WORKDIR /app
COPY --from=deps /app/node_modules /app/node_modules
COPY --from=builder /app/dist /app/

CMD [ "node", "index.js" ]

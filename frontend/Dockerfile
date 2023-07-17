##################### Build Stage #####################
FROM artifactory.pfizer.com/mxs/node:16-alpine AS builder

WORKDIR /app
# Install Dependencies
COPY package.json yarn.lock ./
RUN apk add --no-cache libc6-compat && \
    yarn install --production --ignore-scripts --prefer-offline --frozen-lockfile --network-concurrency 1

# Make sure we have enough memory during build
ENV NODE_OPTIONS "--max-old-space-size=2048"
# Copy source code, and build the application
COPY . .
RUN yarn build

################## Production Stage ###################
FROM artifactory.pfizer.com/mxs/nginx:stable-alpine

# Copy the production bundle to be hosted by nginx.
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

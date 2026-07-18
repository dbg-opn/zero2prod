# Builder stage
# latest Rust stable release as base image
FROM rust:1.97.0 AS builder

# switch workdir to `app`, same as `cd app`
# creates a new directory with the name if it does not exist
WORKDIR /app
# install required dependencies for linking config to work
RUN apt update && apt install lld clang -y
# copy all files from out work dir to our docker image /app dir
COPY . .
# use cached sqlx queries
ENV SQLX_OFFLINE=true
# build in release mode
RUN cargo build --release

# Runtime stage
FROM rust:1.97.0 AS runtime

WORKDIR /app
# Copy compiled binary from builder environment
# to the runtime environment
COPY --from=builder /app/target/release/zero2prod zero2prod
# copy the config file for runtime read
COPY configuration configuration
# load production config (0.0.0.0)
ENV APP_ENVIRONMENT=production
# when `docker run` is executed, launch the binary
ENTRYPOINT ["./target/release/zero2prod"]

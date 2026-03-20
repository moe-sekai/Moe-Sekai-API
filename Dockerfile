FROM rust:1.92-alpine AS builder
RUN apk add --no-cache musl-dev openssl-dev openssl-libs-static cmake make perl
WORKDIR /app
COPY . .
ARG VERSION=dev
RUN if [ "$VERSION" != "dev" ]; then \
    CLEAN_VERSION=$(echo "$VERSION" | sed 's/^v//'); \
    sed -i "s/^version = \".*\"/version = \"${CLEAN_VERSION}\"/" Cargo.toml; \
    echo "Building version: ${CLEAN_VERSION}"; \
    fi
RUN cargo build --release

FROM alpine:3.22
RUN apk --no-cache add ca-certificates tzdata wget && addgroup -S app && adduser -S -G app app
WORKDIR /app
COPY --from=builder /app/target/release/moe-sekai-api .
COPY Data ./Data
COPY moe-sekai-configs.example.yaml /app/moe-sekai-configs.example.yaml
RUN mkdir -p /data /app && chown -R app:app /app /data
VOLUME ["/data"]
EXPOSE 9999
ENV TZ=Asia/Shanghai
ENV RUST_LOG=info
ENV CONFIG_PATH=/data/moe-sekai-configs.yaml
ARG VERSION=dev
LABEL org.opencontainers.image.version="${VERSION}"
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 CMD wget -qO- "http://127.0.0.1:${PORT:-9999}/health" >/dev/null 2>&1 || exit 1
USER app
CMD ["./moe-sekai-api"]

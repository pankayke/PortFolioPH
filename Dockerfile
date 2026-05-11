# ──────────────────────────────────────────────────────────────────────────────
# Stage 1 — Build the Flutter web app
# ──────────────────────────────────────────────────────────────────────────────
FROM debian:bookworm-slim AS build

# System dependencies needed by Flutter tooling
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        unzip \
        xz-utils \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Pin to the exact Flutter version used in development
ARG FLUTTER_VERSION=3.38.7
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN curl -fL \
        --http1.1 \
        --retry 5 \
        --retry-delay 10 \
        --retry-connrefused \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        -o /tmp/flutter.tar.xz && \
    tar -xJf /tmp/flutter.tar.xz -C /opt && \
    rm /tmp/flutter.tar.xz && \
    git config --global --add safe.directory /opt/flutter

# Precache only the web artifacts — keeps the layer small
RUN flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows

WORKDIR /app

# Copy dependency manifest first so pub get is cached as long as pubspec
# doesn't change (improves rebuild speed)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build optimised web release.
# --base-href / keeps all asset paths absolute so nginx can serve from root.
RUN flutter build web \
        --release \
        --base-href / \
        --dart-define=FLUTTER_WEB_USE_SKIA=true

# ──────────────────────────────────────────────────────────────────────────────
# Stage 2 — Serve with nginx (minimal alpine image)
# ──────────────────────────────────────────────────────────────────────────────
FROM nginx:1.28-alpine AS serve

# Write the nginx config directly so the frontend build does not depend on a
# separate file being present in the build context.
RUN cat <<'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    charset utf-8;

    types {
        application/wasm                   wasm;
        application/javascript             js mjs;
        text/html                          html htm;
        text/css                           css;
        image/png                          png;
        image/jpeg                         jpg jpeg;
        image/svg+xml                      svg svgz;
        application/json                   json;
        font/woff2                         woff2;
        font/woff                          woff;
    }

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        image/svg+xml
        font/woff
        font/woff2;

    add_header X-Frame-Options       "SAMEORIGIN"  always;
    add_header X-Content-Type-Options "nosniff"    always;
    add_header Referrer-Policy       "strict-origin-when-cross-origin" always;

    location = /sqflite_sw.js {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        try_files $uri =404;
    }

    location /assets/ {
        add_header Cache-Control "public, max-age=31536000, immutable";
        try_files $uri =404;
    }

    location /canvaskit/ {
        add_header Cache-Control "public, max-age=31536000, immutable";
        try_files $uri =404;
    }

    location ~* \.wasm$ {
        add_header Cache-Control "public, max-age=31536000, immutable";
        add_header Cross-Origin-Embedder-Policy "require-corp";
        add_header Cross-Origin-Opener-Policy   "same-origin";
        try_files $uri =404;
    }

    location ~* main\.dart\.js$ {
        add_header Cache-Control "no-store";
        try_files $uri =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

# Copy built Flutter web assets from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run /etc/nginx/conf.d

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO /dev/null http://127.0.0.1:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

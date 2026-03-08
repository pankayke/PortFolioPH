# ──────────────────────────────────────────────────────────────────────────────
# Stage 1 — Build the Flutter web app
# ──────────────────────────────────────────────────────────────────────────────
FROM debian:bookworm-slim AS build

# System dependencies needed by Flutter tooling
RUN apt-get update && \
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
FROM nginx:1.27-alpine AS serve

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Flutter web assets from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO /dev/null http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

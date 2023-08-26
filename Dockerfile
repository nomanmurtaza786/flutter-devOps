# Stage 1
FROM debian:latest AS build-env

RUN apt-get update 
RUN apt install -y \
    curl git wget python3 \
    zip unzip apt-transport-https \
    ca-certificates gnupg clang \
    cmake ninja-build pkg-config \
    libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback \
    libgtk-3-dev
RUN apt clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter build web

# Stage 2
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

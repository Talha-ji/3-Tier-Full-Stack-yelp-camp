FROM node:16.17.0-alpine as builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
# Pass TMDB API key as build argument (replace with your actual key)
ARG TMDB_V3_API_KEY=54026591ca497ca6e52c8910d1ad268d
# Set environment variable for Vite (React/Vue) to use
ENV VITE_APP_TMDB_V3_API_KEY=$TMDB_V3_API_KEY
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
# Copy custom Nginx config (for SPA routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

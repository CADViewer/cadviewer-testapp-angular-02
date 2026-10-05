# CADViewer Angular sample - static build served by nginx (Coolify build pack: Dockerfile).

FROM node:22-bookworm-slim AS build
WORKDIR /app

COPY package.json package-lock.json ./
# typescript 6 is newer than the peer range of @angular-devkit/build-angular 21
RUN npm ci --no-audit --no-fund --legacy-peer-deps

COPY . .
# CADViewer conversion server used by the production build
ARG SERVER_BACKEND_URL=http://localhost:3000/
RUN sed -i "s|serverBackEndUrl: \"[^\"]*\"|serverBackEndUrl: \"${SERVER_BACKEND_URL}\"|" src/environments/environment.prod.ts \
    && npx ng build --configuration production

FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/cadviewer-testapp-angular-v19/browser /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1

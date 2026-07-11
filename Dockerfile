ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.17.6"
ARG NODE_VERSION="24-alpine"
FROM $DOCKER_HUB/library/node:$NODE_VERSION as build
COPY . /workspace/
ARG NPM_REGISTRY=" https://registry.npmjs.org"
RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc                              && \
    cd /workspace/                                                                       && \
    npm ci                                                                               && \
    npm run build -- --configuration production                                          
FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime
COPY --from=build /workspace/dist/browser/ /usr/share/nginx/html/
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx                        && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
EXPOSE 8080
USER nginx
HEALTHCHECK     CMD     [ "service", "nginx", "status" ]


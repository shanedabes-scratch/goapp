# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-goapp"
LABEL REPO="https://github.com/shanedabes/goapp"

ENV PROJPATH=/go/src/github.com/shanedabes/goapp

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/shanedabes/goapp
WORKDIR /go/src/github.com/shanedabes/goapp

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/shanedabes/goapp"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/goapp/bin

WORKDIR /opt/goapp/bin

COPY --from=build-stage /go/src/github.com/shanedabes/goapp/bin/goapp /opt/goapp/bin/
RUN chmod +x /opt/goapp/bin/goapp

# Create appuser
RUN adduser -D -g '' goapp
USER goapp

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/goapp/bin/goapp"]

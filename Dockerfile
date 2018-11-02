FROM golang:1.11-alpine AS build
ARG PROTOTOOL_VERSION=1.3.0
ARG PROTOC_VERSION=3.6.1
ARG PROTOC_GEN_GO_VERSION=1.2.0
ARG PROTOC_GEN_GOGO_VERSION=1.1.1
ARG PROTOC_GEN_JAVA_GRPC_VERSION=1.16.1
ARG PROTOC_GEN_VALIDATE_VERSION=0.0.10

RUN apk --no-cache add --update curl git libc6-compat make
RUN \
  curl -sSL https://github.com/uber/prototool/releases/download/v$PROTOTOOL_VERSION/prototool-Linux-x86_64 -o /bin/prototool && \
  chmod +x /bin/prototool
RUN \
  mkdir /tmp/prototool-bootstrap && \
  echo $'protoc:\n  version:' $PROTOC_VERSION > /tmp/prototool-bootstrap/prototool.yaml && \
  echo 'syntax = "proto3";' > /tmp/prototool-bootstrap/tmp.proto && \
  prototool compile /tmp/prototool-bootstrap && \
  rm -rf /tmp/prototool-bootstrap
RUN go get github.com/golang/protobuf/... && \
  cd /go/src/github.com/golang/protobuf && \
  git checkout v$PROTOC_GEN_GO_VERSION && \
  go install ./protoc-gen-go
RUN go get github.com/gogo/protobuf/... && \
  cd /go/src/github.com/gogo/protobuf && \
  git checkout v$PROTOC_GEN_GOGO_VERSION && \
  go install ./protoc-gen-gogofast ./protoc-gen-gogofaster ./protoc-gen-gogoslick
RUN go get -d github.com/lyft/protoc-gen-validate && \
  cd /go/src/github.com/lyft/protoc-gen-validate && \
  git checkout v$PROTOC_GEN_VALIDATE_VERSION && \
  make build
RUN curl -sSL https://search.maven.org/remotecontent?filepath=io/grpc/protoc-gen-grpc-java/$PROTOC_GEN_JAVA_GRPC_VERSION/protoc-gen-grpc-java-$PROTOC_GEN_JAVA_GRPC_VERSION-linux-x86_64.exe -o /bin/protoc-gen-grpc-java && \
    chmod +x /bin/protoc-gen-grpc-java

FROM alpine:3.8
WORKDIR /in
RUN apk --no-cache add --update libc6-compat 
COPY --from=build /bin/prototool /bin/prototool
COPY --from=build /root/.cache/prototool /.cache/prototool
COPY --from=build /go/bin/protoc-gen-go /bin/protoc-gen-go
COPY --from=build /go/bin/protoc-gen-gogofast /bin/protoc-gen-gogofast
COPY --from=build /go/bin/protoc-gen-gogofaster /bin/protoc-gen-gogofaster
COPY --from=build /go/bin/protoc-gen-gogoslick /bin/protoc-gen-gogoslick
COPY --from=build /go/bin/protoc-gen-validate /bin/protoc-gen-validate
COPY --from=build /go/src/github.com/lyft/protoc-gen-validate/validate /include/validate
COPY --from=build /bin/protoc-gen-grpc-java /bin/protoc-gen-grpc-java

RUN chmod -R 755 /.cache
ENTRYPOINT ["/bin/prototool"]



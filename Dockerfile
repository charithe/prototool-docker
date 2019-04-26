FROM golang:1.12.4-alpine3.9 AS build

ARG PROTOTOOL_VERSION=1.6.0
ARG PROTOC_GEN_JAVA_GRPC_VERSION=1.20.0
ARG GOLANG_PROTOBUF_VERSION=1.3.1
ARG GOGO_PROTOBUF_VERSION=1.2.1
ARG GRPC_GATEWAY_VERSION=1.8.5
ARG GRPC_WEB_VERSION=1.0.4

RUN apk --no-cache add --update curl git libc6-compat make upx

RUN GO111MODULE=on go get \
  github.com/uber/prototool/cmd/prototool@v${PROTOTOOL_VERSION} && \
  mv /go/bin/prototool /usr/local/bin

RUN GO111MODULE=on go get \
  github.com/golang/protobuf/protoc-gen-go@v${GOLANG_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gofast@v${GOGO_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogo@v${GOGO_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogofast@v${GOGO_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogofaster@v${GOGO_PROTOBUF_VERSION} \
  github.com/gogo/protobuf/protoc-gen-gogoslick@v${GOGO_PROTOBUF_VERSION} && \
  mv /go/bin/protoc-gen-go* /usr/local/bin/ 
  
RUN go get -d github.com/gogo/protobuf/gogoproto && \
  mkdir -p /usr/include/gogoproto && \
  mv /go/src/github.com/gogo/protobuf/gogoproto/gogo.proto /usr/include/gogoproto/gogo.proto

RUN curl -sSL \
  https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v${GRPC_GATEWAY_VERSION}/protoc-gen-grpc-gateway-v${GRPC_GATEWAY_VERSION}-linux-x86_64 \
  -o /usr/local/bin/protoc-gen-grpc-gateway && \
  curl -sSL \
  https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v${GRPC_GATEWAY_VERSION}/protoc-gen-swagger-v${GRPC_GATEWAY_VERSION}-linux-x86_64 \
  -o /usr/local/bin/protoc-gen-swagger && \
  chmod +x /usr/local/bin/protoc-gen-grpc-gateway && \
  chmod +x /usr/local/bin/protoc-gen-swagger

RUN curl -sSL \
  https://github.com/grpc/grpc-web/releases/download/${GRPC_WEB_VERSION}/protoc-gen-grpc-web-${GRPC_WEB_VERSION}-linux-x86_64 \
  -o /usr/local/bin/protoc-gen-grpc-web && \
  chmod +x /usr/local/bin/protoc-gen-grpc-web

RUN go get -d github.com/envoyproxy/protoc-gen-validate && \
  cd /go/src/github.com/envoyproxy/protoc-gen-validate && \
  make build && \
  mv /go/bin/protoc-gen-validate /usr/local/bin && \
  mkdir -p /usr/include/validate && \
  mv /go/src/github.com/envoyproxy/protoc-gen-validate/validate/validate.proto /usr/include/validate/validate.proto

RUN curl -sSL https://search.maven.org/remotecontent?filepath=io/grpc/protoc-gen-grpc-java/$PROTOC_GEN_JAVA_GRPC_VERSION/protoc-gen-grpc-java-$PROTOC_GEN_JAVA_GRPC_VERSION-linux-x86_64.exe -o /usr/local/bin/protoc-gen-grpc-java && \
    chmod +x /usr/local/bin/protoc-gen-grpc-java

RUN upx --lzma /usr/local/bin/*

FROM alpine:3.9
ENV PROTOTOOL_CACHE_PATH=/tmp
ENV LD_LIBRARY_PATH=/lib64:/lib
WORKDIR /work
RUN apk --no-cache add --update ca-certificates libc6-compat
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/include /usr/include 
RUN chmod -R 755 /usr/include

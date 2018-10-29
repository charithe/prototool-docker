FROM golang:1.11
ARG PROTOTOOL_URL=https://github.com/uber/prototool/releases/download/v1.3.0/prototool-Linux-x86_64
ARG GRPC_JAVA_URL=https://search.maven.org/remotecontent?filepath=io/grpc/protoc-gen-grpc-java/1.16.1/protoc-gen-grpc-java-1.16.1-linux-x86_64.exe
RUN apt-get update && apt-get install -y wget git
RUN mkdir /prototool /.cache && chmod 777 /.cache
WORKDIR /prototool
RUN wget -O prototool $PROTOTOOL_URL && chmod +x prototool
RUN wget -O protoc-gen-grpc-java $GRPC_JAVA_URL && chmod +x protoc-gen-grpc-java
RUN go get -u github.com/gogo/protobuf/proto github.com/gogo/protobuf/protoc-gen-gogoslick github.com/gogo/protobuf/gogoproto
ENTRYPOINT ["/prototool/prototool"]


Prototool Docker Helper
=======================

[![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg?style=flat-square)](https://hub.docker.com/r/charithe/prototool-docker/)


Docker image with [prototool](https://github.com/uber/prototool), [gogoproto](https://github.com/gogo/protobuf),
[protoc-gen-validate](https://github.com/lyft/protoc-gen-validate) and `protoc-gen-grpc-java` pre-installed.

The accompanying `prototool.sh` script mounts the current working directory as `/in` and runs the Docker image
as the current user. This results in the generated artifacts having the correct permissions.


Installation
------------

```shell
curl -o prototool.sh https://raw.githubusercontent.com/charithe/prototool-docker/v0.0.3/prototool.sh
```

Optionally, add `prototool.sh` to your `PATH`.

Usage
-----

Create a `prototool.yaml` file in your project root as usual. For example:

```yaml
protoc:
  version: 3.6.1
  include:
    - /include

lint:
  rules:
    remove:
      - FILE_OPTIONS_EQUAL_JAVA_PACKAGE_COM_PREFIX

generate:
  go_options:
    import_path: github.com/charithe/grpc-gizmo

  plugins:
    - name: gogofast
      type: gogo
      path: /bin/protoc-gen-gogofast
      flags: plugins=grpc
      output: ./go/pkg/v1pb
    - name: validate
      path: /bin/protoc-gen-validate
      flags: lang=go
      output: ./go/pkg/v1pb
    - name: java
      output: ./java/src/main/java
    - name: grpc-java
      path: /bin/protoc-gen-grpc-java
      output: ./java/src/main/java
```

Prototool can now be invoked as follows:

```shell
# Lint
/path/to/prototool.sh lint 

# Compile
/path/to/prototool.sh compile 

# All
/path/to/prototool.sh all 
```


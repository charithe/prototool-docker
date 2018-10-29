Prototool Docker Helper
=======================

Docker image with [prototool](https://github.com/uber/prototool), [gogoproto](https://github.com/gogo/protobuf) and 
`protoc-gen-grpc-java` pre-installed.

The accompanying `prototool.sh` script mounts the current working directory as `/input` and runs the Docker image
as the current user.

Installation
------------

Clone the repo and run `make` to build the Docker image

Usage
-----

Create a `prototool.yaml` file in your project root as usual. For example:

```yaml
protoc:
  version: 3.6.1

lint:
  rules:
    remove:
      - ENUM_FIELD_PREFIXES
      - ENUM_ZERO_VALUES_INVALID

generate:
  go_options:
    import_path: github.com/charithe/grpc-gizmo

  plugins:
    - name: gogoslick
      type: gogo
      flags: plugins=grpc
      output: ./go/pkg/v1pb
    - name: java
      output: ./java/src/main/java
    - name: grpc-java
      path: /prototool/protoc-gen-grpc-java
      output: ./java/src/main/java

```

Prototool can now be invoked as follows:

```shell
# Lint
/path/to/prototool.sh lint /input

# Compile
/path/to/prototool.sh compile /input

# All
/path/to/prototool.sh all /input
```


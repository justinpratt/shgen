#!/bin/sh -e

platforms="ubuntu alpine"

for platform in ${platforms}; do
  printf '\n##############################\n# %s\n' "${platform}"
  docker buildx build -f "Dockerfile.${platform}" -t "${platform}-shgen" .
  docker buildx build -f- -t "${platform}-shgen-test" . <<HERE
FROM ${platform}-shgen
RUN mkdir /app
COPY ./ /app/
WORKDIR /app
CMD ./test.sh
HERE
  docker run -it --rm "${platform}-shgen-test"
done

#!/bin/bash
set -eu

function generate_manifests {
  echo "Cleanup generated manifests"
  rm -rf ./clusters

  TEMPLATES_DIR="/tmp/generate/templates"
  VALUES_DIR="/tmp/generate/values"
  OUTPUT_DIR="/tmp/clusters"

  # reads the common.yaml found from jore4-flux repository
  GOMPLATE_CMD="docker run --rm -v $(pwd):/tmp hairyhenderson/gomplate:stable-alpine \
    --template templates=$TEMPLATES_DIR/resources/ \
    -d common=git+https://github.com/HSLdevcom/jore4-flux//generate/values/common.yaml"
  echo "Generating docker-compose file and secrets with gomplate"

  $GOMPLATE_CMD \
    --input-dir "$TEMPLATES_DIR/docker-compose" \
    --output-dir "$OUTPUT_DIR/docker-compose" \
    -d "e2e=$VALUES_DIR/e2e.yaml" \
    -c "Values=merge:e2e|common"
}

function super_linter {
  echo "Running Super-Linter"

  docker run --rm -e RUN_LOCAL=true -e VALIDATE_GITLEAKS=false -e VALIDATE_JSCPD=false -e VALIDATE_GITHUB_ACTIONS=false -v "$(pwd)":/tmp/lint github/super-linter:v4
}

function toc {
  echo "Refreshing Table of Contents"

  npx doctoc@2.2.0 README.md
}

function usage {
  echo "
  Usage $0 <command>

  generate
    Generates Kubernetes and docker-compose manifests for all stages using gomplate yaml templates.

  lint
    Runs Github's Super-Linter for the whole codebase to lint all files.

  toc
    Refreshes the Table of Contents in the README.

  help
    Show this usage information
  "
}

case $1 in
generate)
  generate_manifests
  ;;

lint)
  super_linter
  ;;

toc)
  toc
  ;;

help)
  usage
  ;;

*)
  usage
  ;;
esac

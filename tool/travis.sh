#!/bin/bash

# Fast fail the script on failures.
set -e

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings \
  lib/md_proc.dart \
  lib/src/definitions.dart \
  lib/src/entities.dart \
  lib/src/html_writer.dart \
  lib/src/markdown_parser.dart \
  lib/src/markdown_writer.dart \
  lib/src/options.dart \
  test/parser.dart \
  test/service.dart \
  test/library_test.dart

# Run the tests.
pub run test

# If the COVERALLS_TOKEN token is set on travis
# Install dart_coveralls
# Rerun tests with coverage and send to coveralls
if [ "$COVERALLS_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/library_test.dart
fi

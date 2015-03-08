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
  test/parser_test.dart \
  test/service_test.dart \
  test/all_tests.dart

# Run the tests.
dart --checked test/all_tests.dart

# If the COVERALLS_TOKEN token is set on travis
# Install dart_coveralls
# Rerun tests with coverage and send to coveralls
if [ "$COVERALLS_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all_tests.dart
fi

#!/bin/bash

# Fast fail the script on failures.
set -e

# Verify that the libraries are error free.
dartanalyzer --strong --fatal-warnings \
  lib/md_proc.dart \
  test/library_test.dart \
  tool/build.dart \
  tool/reporter.dart

# Run the tests.
echo "Running tests"
pub run test --reporter json -p "vm" | dart tool/reporter.dart

# If the COVERALLS_TOKEN token is set on travis
# Install dart_coveralls
# Rerun tests with coverage and send to coveralls
if [ "$COVERALLS_TOKEN" ]; then
  echo "Gathering tests coverage"
  pub run dart_coveralls report \
    --token $COVERALLS_TOKEN \
    --retry 2 \
    test/library_test.dart > /dev/null
fi

echo "Done"

# Elm Test Runner

Run elm-test and view results without leaving Atom

## Setup

1. Install [`node-test-runner`](https://github.com/rtfeldman/node-test-runner). This makes the `elm-test` command available on the command line, which is a requirement to use Elm Test Runner. Elm Test Runner currently requires elm-test version 0.18.9.
2. Install `elm-test-runner` in Atom.
    1. In Atom, go to Atom → Preferences...
    2. Click "Install".
    3. Search for "elm-test-runner".
    4. Find "elm-test-runner" in the list and click the "install" button.

## Feature Overview

### Run Tests Without Leaving Atom

1. Open a project folder that has Elm tests in it. Typically, this is a directory that has a `tests` directory, and that `tests` directory contains Elm files that expose functions of type `Test`. I recommend you set up your test directory with `elm-test init` in order to ensure compatibility.
2. Go to Packages → Elm Test Runner → Toggle Dashboard, or use Cmd-Alt-T to open the test pane.
3. Click the "Run All" button, or use Cmd-T to run tests.
4. Wait for the test run to complete.
5. Click on individual failing tests to view the failure results for those tests.

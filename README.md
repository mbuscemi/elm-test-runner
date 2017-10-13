# Elm Test Runner

Run elm-test and view results without leaving Atom

<p style="text-align: center;">
    <img src="https://github.com/mbuscemi/elm-test-runner/blob/master/images/elm-test-runner.png" alt="Elm Test Runner" style="width: 380px;" />
</p>

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

### Seed Utilities

1. Toggle the "Seed" checkbox on and off in the lower left corner of the pane. If the checkbox is active, the number in the adjacent field will used when running `elm-test`. If the box is unchecked, or if the number field is empty (it will read "Generate Random"), then a random seed will be used.
2. To lock-in the seed for the last test run, click the "Set" button. This will set the seed the number field and activate the "Seed" checkbox if it is not already active.
3. To copy the seed for the last test run to the clipboard, click the "Copy" button. This will allow you to paste the seed into another location.

### Auto-Run Tests on Save

1. Go to Packages → Elm Test Runner → Toggle Auto-Run on Save, or use Ctrl-R to toggle 'Auto-Run on Save' on and off. When it is active, an indicator will light up in the lower right hand corner of the pane.
2. When 'Auto-Run on Save' is enabled, executing a "save" action on any project file will initiate a test run in Elm Test Runner.

# Elm Test Runner

Run elm-test and view results without leaving Atom

![Elm Test Runner](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/elm-test-runner-animated-header-only.gif?raw=true)

## Setup

1. Install `elm-test-runner` in Atom.
    1. In Atom, go to Atom → Preferences...
    2. Click "Install".
    3. Search for "elm-test-runner".
    4. Find "elm-test-runner" in the list and click the "install" button.

## Feature Overview

### Run Tests Without Leaving Atom

![Running Tests](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/menu.png?raw=true)

1. Open a project folder that has Elm tests in it. Typically, this is a directory that has an `elm-package.json` file, a `tests` directory that contains Elm files exposing functions of type `Test`. I recommend that you set up your test directory with `elm-test init` in order to ensure compatibility.
2. Go to Packages → Elm Test Runner → Toggle Dashboard, or use ⌘-Alt-T to open the test pane.
3. Click the "Run All" button, or use ⌘-T to run tests.
4. Wait for the test run to complete.
5. Click on individual failing tests to view the failure results for those tests.

### Dock Left, Right, or Center

![Vertical Layout—Left & Right Dock](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/layout-vertical.png?raw=true)
![Horizontal Layout—Bottom Dock](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/layout-horizontal.png?raw=true)

1. Drag the header bar for Elm Test Runner from its default position on the right side of the screen into the lower dock, or the left dock.
2. Elm Test Runner will move to that dock. Landscape orientation for the center bottom dock is supported.

### Seed Utilities

![Setting the Seed](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/set-seed-example.gif?raw=true)

1. Toggle the "Seed" checkbox on and off in the lower left corner of the pane. If the checkbox is active, the number in the adjacent field will be used when running `elm-test`. If the box is unchecked, or if the number field is empty (it will read "Generate Random"), then a random seed will be used.
2. To lock-in the seed used on the last test run, click the "Set" button. This will set the seed the number field and activate the "Seed" checkbox if it is not already active.
3. To copy the seed for the last test run to the clipboard, click the "Copy" button. This will allow you to paste the seed into another location.

### Auto-Run Tests on Save

1. Go to Packages → Elm Test Runner → Toggle Auto-Run on Save, or use Ctrl-R to toggle 'Auto-Run on Save' on and off. When it is active, an indicator will light up in the lower right hand corner of the pane.
2. When 'Auto-Run on Save' is enabled, executing a "save" action on any project file will initiate a test run in Elm Test Runner.

### Auto-Navigate to Test

1. Click on a passing or failing test, and the file containing the selected test will open in your editor.*
2. Auto-Navigate to Test is enabled by default. You can disable it by going to Packages → Elm Test Runner → Toggle Auto-Navigate to Test, or by using ⌘-Alt-N. An indicator light in the lower right hand corner of the pane indicates whether this functionality is enabled or disabled.

**Important Caveat:** Only files that are in the current active Atom project are capable of being opened in this way.

## Release History

### 0.1.0

* Basic interface with run button
* Displays test passes, failures, and failure output
* Can click on a test to auto-navigate to the test file and location
* Key bindings and package menu entries
* Test pane dockable in all docks
* Can copy seed from a run
* Can set seed for a run
* Can enable/disable auto-run on save
* Can enable/disable auto-navigation to file when clicking on a test

### 0.1.1

* README fixes
    * Minor correction to setup instructions.
    * Fixed broken images on Atom package page.

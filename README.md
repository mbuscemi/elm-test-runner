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

![Running Tests](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/menu-example.png?raw=true)

1. Open a project folder that has Elm tests in it. Typically, this is a directory that has an `elm-package.json` file, a `tests` directory that contains Elm files exposing functions of type `Test`. I recommend that you set up your test directory with `elm-test init` in order to ensure compatibility.
2. Go to Packages → Elm Test Runner → Toggle Dashboard, or use ⌘-Alt-T to open the test pane.
3. Click the "Run All" button, or use Alt-T to run tests.
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

### Test Generation with _Elm Verify Examples_

![Generating Tests](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/elm-verify-examples-enabled.gif?raw=true)
![Accessing Settings](https://raw.githubusercontent.com/mbuscemi/elm-test-runner/master/images/how-to-show-settings.gif?raw=true)

1. To see the current state of this setting, toggle the settings panel open by clicking on the gear icon in the lower right corner of the panel.
2. To change this setting:
    * Click the checkbox next to the option
    * Go to Packages → Elm Test Runner → Toggle Running with 'Elm Verify Examples'
    * Use the key command Ctrl-Alt-V
3. When initiating a test run, Elm Test Runner will first run `elm-verify-examples` in your project directory before proceeding to run `elm-test`. The status bar at the top Elm Test Runner panel will indicate when tests are being generated as opposed to being run.

### Auto-Run Tests on Save

1. To see the current state of this setting, toggle the settings panel open by clicking on the gear icon in the lower right corner of the panel.
2. To change this setting:
    * Click the checkbox next to the option
    * Go to Packages → Elm Test Runner → Toggle Auto-Run on Save
    * Use the key command Ctrl-Alt-R
3. When 'Auto-Run on Save' is enabled, executing a "save" action on any project file will initiate a test run in Elm Test Runner.

### Auto-Navigate to Test

1. Click on a passing or failing test, and the file containing the selected test will open in your editor.*
2. To see the current state of this setting, toggle the settings panel open by clicking on the gear icon in the lower right corner of the panel.
3. To change this setting:
    * Click the checkbox next to the option
    * Go to Packages → Elm Test Runner → Toggle Auto-Navigate to Test
    * Use the command key Ctrl-Alt-N

**Important Caveat:** Only files that are in the current active Atom project are capable of being opened in this way.

## Release History

* [Elm Test Runner Release History](https://github.com/mbuscemi/elm-test-runner/releases)

'use babel';

import { BufferedNodeProcess } from 'atom';
import { NotificationManager } from 'atom';

import fs from 'fs';
import path from 'path';
import shell from 'shell';

export default class ElmTestCommand {

    constructor(elm) {
        this.elm = elm;
    }

    /* ==============================
        PUBLIC
       ============================== */

    run(useElmVerifyExamples, projectDirectory, seed) {
        if (useElmVerifyExamples) {
            this.runElmVerifyExamples(projectDirectory, seed);
        } else {
            this.runElmTest(projectDirectory, seed);
        }
    }

    deactivate() {
        if (this.elmTestProcess) {
            this.elmTestProcess.kill();
            delete this.elmTestProcess;
        }

        if (this.elmVerifyExmaplesProcess) {
            this.elmVerifyExmaplesProcess.kill();
            delete this.elmVerifyExmaplesProcess;
        }
    }

    /* ==============================
        PRIVATE
       ============================== */

    runElmTest(projectDirectory, seed) {
        const command = atom.config.get("elm-test-runner.elm-test-path");
        const args = this.makeElmTestArgs(seed);
        const options = { cwd: projectDirectory };
        const stdout = (output) => this.processStdout(output);
        const stderr = (error) => this.processStderr(error);
        const exit = (code) => this.processExit(code);

        if (projectDirectory && fs.existsSync(projectDirectory)) {
            this.elm.ports.notifyExecutingTests.send(null);
            this.elmTestProcess = new BufferedNodeProcess({command, args, options, stdout, stderr, exit});
        } else {
            this.showPathErrorMessage();
        }
    }

    runElmVerifyExamples(projectDirectory, seed) {
        const command = atom.config.get("elm-test-runner.elm-verify-examples-path");
        const args = [];
        const options = { cwd: projectDirectory };
        const stdout = (output) => {};
        const stderr = (error) => this.processStderr(error);
        const exit = (code) => this.runElmTest(projectDirectory, seed);

        if (projectDirectory && fs.existsSync(projectDirectory)) {
            this.elm.ports.notifyGeneratingTests.send(null);
            this.elmVerifyExmaplesProcess = new BufferedNodeProcess({command, args, options, stdout, stderr, exit});
        } else {
            this.showPathErrorMessage();
        }
    }

    makeElmTestArgs(seed) {
        let args = ["--report", "json"]

        if (seed && seed.length > 0) {
            args.push("--seed");
            args.push(seed)
        }

        return args;
    }

    processStdout(output) {
        let testJsons = output.split('\n');
        testJsons.forEach((jsonString) => {
            if (jsonString.length > 0) {
                this.processTest(jsonString);
            }
        });
    }

    processStderr(error) {
        this.elm.ports.notifyCompilerErrored.send(error);
    }

    processExit(code) {}

    showPathErrorMessage() {
        const pathErrorMessage = "<strong>Could not locate Elm project directory, or directory does not exist.</strong> " +
            "Elm Test Runner scans your project for directories that have both an elm-package.json file and a `tests` " +
            "subdirectory. You can click the button below to rescan your project if a project directory has moved.";

        atom.notifications.addError(pathErrorMessage, {
            dismissable: true,
            buttons: [
                {
                    text: "Re-Scan Project",
                    className: "btn icon icon-sync",
                    onDidClick: () => atom.commands.dispatch(
                        atom.views.getView(atom.workspace),
                        "elm-test-runner:scan-for-directories"
                    )
                },
                {
                    text: "File Bug",
                    className: "btn icon icon-bug",
                    onDidClick: () => shell.openExternal("https://github.com/mbuscemi/elm-test-runner/issues")
                }
            ]
        });
    }

    processTest(testJsonString) {
        try {

            let testJson = JSON.parse(testJsonString);
            if (testJson.event == "runStart") {
                this.elm.ports.runStart.send(testJson);
            } else if (testJson.event == "testCompleted") {
                this.elm.ports.testCompleted.send(testJson);
            } else if (testJson.event == "runComplete") {
                this.elm.ports.runComplete.send(testJson);
            } else {
                console.log("ERROR: unrecognized event type \"" + testJson.event + "\"")
            }

        } catch (error) {
            console.log(error);
            console.log("Truncated JSON sent to stdout: \"" + testJsonString + "\"");
        }
    }

}

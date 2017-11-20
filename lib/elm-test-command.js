'use babel';

import { BufferedNodeProcess } from 'atom';
import { NotificationManager } from 'atom';

import path from 'path';

export default class ElmTestCommand {

    constructor(elm, elmProjectPath) {
        this.elm = elm;
        this.elmProjectPath = elmProjectPath;
        this.command = atom.config.get('elm-test-runner.elm-test-path');
    }

    /* ==============================
        PUBLIC
       ============================== */

    run(seed) {
        const command = this.command;
        const args = this.makeArgs(seed);

        this.projectPath = this.elmProjectPath.generate();
        const options = { cwd: this.projectPath };

        const stdout = (output) => this.processStdout(output);
        const stderr = (error) => this.processStderr(error);
        const exit = (code) => this.processExit(code);

        if (this.projectPath) {
            this.elmTestProcess = new BufferedNodeProcess({command, args, options, stdout, stderr, exit});
        } else {
            this.showPathErrorMessage();
        }
    }

    /* ==============================
        PRIVATE
       ============================== */

    makeArgs(seed) {
        let args = ['--report', 'json']

        if (seed && seed.length > 0) {
            args.push('--seed');
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
        const pathErrorMessage = "<strong>Could not locate Elm project directory.</strong> " +
            "This error can be remedied one of two ways. 1) Open up a project directory in " +
            "Atom that contains an elm-package.json file. 2) Open a file in Atom " +
            "with an elm-package.json file in one of the directories contained within its path. " +
            "Make sure this directory also has a `tests` directory with Elm test files inside it, " +
            "or you will get compilation errors.";

        atom.notifications.addError(pathErrorMessage, {dismissable: true});
    }

    processTest(testJsonString) {
        try {

            let testJson = JSON.parse(testJsonString);
            if (testJson.event == "runStart") {
                this.elm.ports.runStart.send([this.projectPath, testJson]);
            } else if (testJson.event == "testCompleted") {
                this.elm.ports.testCompleted.send(testJson);
            } else if (testJson.event == "runComplete") {
                this.elm.ports.runComplete.send(testJson);
            } else {
                console.log("ERROR: unrecognized event type \"" + testJson.event + "\"")
            }

        } catch (error) {
            console.log("Truncated JSON sent to stdout: \"" + testJsonString + "\"");
        }
    }

}

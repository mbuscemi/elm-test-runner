'use babel';

import { BufferedNodeProcess } from 'atom';
import { NotificationManager } from 'atom';

import path from 'path';

export default class ElmTestCommand {

    constructor(elm, elmProjectPath) {
        this.elm = elm;
        this.elmProjectPath = elmProjectPath;

        this.command = path.join(
            atom.workspace.packageManager.getPackageDirPaths()[0],
            "elm-test-runner",
            "node_modules",
            "elm-test",
            "lib",
            "elm-test.js"
        );

        this.stderr = (error) => {
            this.elm.ports.notifyCompilerErrored.send(error);
        };

        this.exit = (code) => {};
    }

    /* ==============================
        PUBLIC
       ============================== */

    run(seed) {
        let args = ['--report', 'json']

        if (seed && seed.length > 0) {
            args.push('--seed');
            args.push(seed)
        }

        let stdout = (output) => {
            let testJsons = output.split('\n');
            testJsons.forEach((jsonString) => {
                if (jsonString.length > 0) {
                    this.processTest(jsonString);
                }
            });
        };

        this.process(args, stdout);
    }

    checkVersion() {
        const targetVersion = "0.18.10";
        const messageTemplate = "<strong>Detected unsupported version of elm-test</strong>. " +
            "Please run `npm upgrade -g elm-test` to update to the latest version. " +
            "Target version is <strong>" + targetVersion + "</strong>, " +
            "but found version <strong>{#.#.#}</strong> on the system.";

        let args = ['--version'];

        let stdout = (output) => {
            if (output.trim() !== targetVersion) {
                let message = messageTemplate.replace("{#.#.#}", output)
                atom.notifications.addWarning(message, {dismissable: true});
            }
        };

        this.process(args, stdout);
    }

    /* ==============================
        PRIVATE
       ============================== */

    process(args, stdout) {
        const pathErrorMessage = "<strong>Could not locate Elm project directory.</strong> " +
            "This error can be remedied one of two ways. 1) Open up a project directory in " +
            "Atom that contains an elm-package.json file. 2) Open a file in Atom " +
            "with an elm-package.json file in one of the directories contained within its path. " +
            "Make sure this directory also has a `tests` directory with Elm test files inside it, " +
            "or you will get compilation errors."

        this.projectPath = this.elmProjectPath.generate();
        const options = { cwd: this.projectPath };

        const command = this.command;
        const stderr = this.stderr;
        const exit = this.exit;

        if (this.projectPath) {
            this.elmTestProcess = new BufferedNodeProcess({command, args, options, stdout, stderr, exit});
        } else {
            atom.notifications.addError(pathErrorMessage, {dismissable: true});
        }
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

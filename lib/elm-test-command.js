'use babel';

import { BufferedProcess } from 'atom';
import { NotificationManager } from 'atom';

export default class ElmTestCommand {

    constructor(elm) {
        this.elm = elm;

        this.command = "elm-test";
        this.options = { cwd: atom.project.getPaths()[0] };

        this.stderr = (error) => {
            this.elm.ports.notifyCompilerErrored.send(null);
            //console.log('found error: ', error)
        };

        this.exit = (code) => {
            //console.log('found code: ', code);
        };
    }

    run(seed) {
        let args = ['--report', 'json']

        if (seed && seed.length > 0) {
            args.push('--seed');
            args.push(seed)
        }

        let stdout = (output) => {
            //console.log('[RUN TEST] console produced output: ', output);
            let testJsons = output.split('\n');
            //console.log('[RUN TEST] split JSONs: ', testJsons);
            testJsons.forEach((jsonString) => this.processTest(jsonString));
        };

        this.process(args, stdout);
    }

    checkVersion() {
        const targetVersion = "0.18.9";
        const messageTemplate = "<strong>Detected obsolete version of elm-test</strong>. " +
            "Please run `npm upgrade -g elm-test` to update to the latest version. " +
            "Target version is <strong>" + targetVersion + "</strong>, " +
            "but found version <strong>{#.#.#}</strong> on the system.";

        let args = ['--version'];

        let stdout = (output) => {
            //console.log('[CHECK VERSION] console produced output: ', output);
            console.log(output);
            console.log(targetVersion);
            if (output.trim() !== targetVersion) {
                let message = messageTemplate.replace("{#.#.#}", output)
                atom.notifications.addWarning(message, {dismissable: true});
            }
        };

        this.process(args, stdout);
    }

    process(args, stdout) {
        const command = this.command;
        const options = this.options;
        const stderr = this.stderr;
        const exit = this.exit;

        let process = new BufferedProcess({command, args, options, stdout, stderr, exit});
    }

    processTest(testJsonString) {
        if (testJsonString != "") {
            //console.log('raw string: ', testJsonString);
            let testJson = JSON.parse(testJsonString);
            //console.log('parsed output: ', testJson);

            if (testJson.event == "runStart") {
                this.elm.ports.runStart.send(testJson);
            } else if (testJson.event == "testCompleted") {
                this.elm.ports.testCompleted.send(testJsonString);
            } else if (testJson.event == "runComplete") {
                this.elm.ports.runComplete.send(testJson);
            } else {
                console.log("ERROR: unrecognized event type \"" + testJson.event + "\"")
            }
        }
    }

}

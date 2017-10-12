'use babel';

import { BufferedProcess } from 'atom';

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
        let args = ['--version'];

        let stdout = (output) => {
            console.log('[CHECK VERSION] console produced output: ', output);
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

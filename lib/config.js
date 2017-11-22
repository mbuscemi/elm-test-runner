'use babel';

import path from 'path';

export default {
    "elm-test-path": {
        title: "Path to Elm Test",
        description: "The path to the elm-test executable",
        type: "string",
        default: path.join(__dirname, "..", "node_modules", "elm-test", "lib", "elm-test.js"),
        order: 10
    },
    "elm-verify-examples-path": {
        title: "Path to Elm Verify Examples",
        description: "The path to the elm-verify-examples executable",
        type: "string",
        default: path.join(__dirname, "..", "node_modules", "elm-verify-examples", "bin", "elm.js"),
        order: 20
    },
}

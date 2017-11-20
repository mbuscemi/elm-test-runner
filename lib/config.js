'use babel';

import path from 'path';

export default {
    "elm-test-path": {
        title: "Path to Elm Test",
        description: "The path to the elm-test executable",
        type: "string",
        default: path.join(__dirname, "..", "node_modules", "elm-test", "lib", "elm-test.js"),
        order: 10
    }
}

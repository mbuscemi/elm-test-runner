'use babel';

export default class ElmProjectPath {

    constructor() {
        console.log("ElmProjectPath.constructor");

        let activePaneItem = atom.workspace.getActivePaneItem();
        console.log("activePaneItem", activePaneItem);

        let buffer = activePaneItem.buffer;
        console.log("buffer", buffer);

        if (buffer) {
            console.log("OPEN FILE FOUND: " + buffer.file.path);
        } else {
            console.log("NO FILE OPEN IN ATOM");
        }

    }

    determine() {

    }

    determineFromActiveFile() {

    }

    determineFromPackageJson() {

    }

}

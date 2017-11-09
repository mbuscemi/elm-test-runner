'use babel';

import fs from 'fs';
import path from 'path';

export default class Navigation {

    constructor(elmProjectPath) {
        this.elmProjectPath = elmProjectPath;
    }

    /* ==============================
        PUBLIC
       ============================== */

    show(filePath, element) {
        let projectPath = this.elmProjectPath.generate();
        let fullPath = path.join(projectPath, filePath);
        let fileExists = fs.existsSync(fullPath);

        if (fileExists) {

            let promise = atom.workspace.open(filePath, { pending: true });
            promise.then((editor) => {
                let numLines = editor.getLineCount();

                for (let line = 0; line < numLines; line++) {
                    let lineText = editor.lineTextForBufferRow(line);
                    let position = lineText.indexOf(element);

                    if (position != -1) {
                        editor.scrollToBufferPosition([line, position]);
                        editor.setCursorBufferPosition([line, position]);
                        break;
                    }
                }
            });

        }
    }

}

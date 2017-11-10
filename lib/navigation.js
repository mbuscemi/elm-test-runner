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

   tryShow(potentialPathPieces, testDescription) {
       let numPieces = potentialPathPieces.length;
       for (let i = numPieces - 1; i > 0; i--) {

           let pathToFile = "tests";
           for (j = 0; j < i; j++) {
               pathToFile = path.join(pathToFile, potentialPathPieces[j]);
           }
           pathToFile += ".elm";

           if (this.canShow(pathToFile)) {
               this.show(pathToFile, testDescription);
               break;
           }

       }
   }

   /* ==============================
       PRIVATE
      ============================== */

    canShow(filePath) {
        let projectPath = this.elmProjectPath.generate();
        let fullPath = path.join(projectPath, filePath);
        return fs.existsSync(fullPath);
    }

    show(filePath, element) {
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

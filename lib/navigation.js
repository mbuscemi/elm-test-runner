'use babel';

import fs from 'fs';
import path from 'path';

export default class Navigation {

    constructor() {}

    /* ==============================
        PUBLIC
       ============================== */

   tryShow(projectPath, potentialPathPieces, testDescription) {
       let numPieces = potentialPathPieces.length;
       for (let i = numPieces - 1; i > 0; i--) {

           let pathToFile = "tests";
           for (j = 0; j < i; j++) {
               pathToFile = path.join(pathToFile, potentialPathPieces[j]);
           }
           pathToFile += ".elm";

           let fullPath = path.join(projectPath, pathToFile);

           if (projectPath && fs.existsSync(fullPath)) {
               this.show(fullPath, testDescription);
               break;
           }

       }
   }

   /* ==============================
       PRIVATE
      ============================== */

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

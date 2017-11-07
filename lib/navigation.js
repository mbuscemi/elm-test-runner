'use babel';

export default class ElmProjectPath {

    constructor() {}

    show(path, element) {
        // console.log(atom.workspace);
        let promise = atom.workspace.open(path, { pending: true });
        promise.then((editor) => {
            // console.log(editor);
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

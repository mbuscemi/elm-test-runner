'use babel';

import fs from 'fs';
import path from 'path';

export default class ElmProjectPath {

    constructor() {}

    /* ==============================
        PUBLIC
       ============================== */

    generateAll() {
        return this.generateFromActiveProjectSubDirectories();
    }

    currentProjectPaths() {
        return atom.project.getPaths();
    }

    /* ==============================
        PRIVATE
       ============================== */

    generateFromActiveProjectSubDirectories() {
        let projectPaths = this.currentProjectPaths();
        if (!projectPaths) { return []; }

        return this.generateFromSubDirectories(projectPaths);
    }

    generateFromSubDirectories(searchPaths) {
        let elmPaths = [];

        for (let i = 0; i < searchPaths.length; i++) {
            let subdirectories = this.subdirectoryList(searchPaths[i]);

            if (this.isElmProjectWithTests(searchPaths[i])) {
                elmPaths.push(searchPaths[i]);
            }

            elmPaths = elmPaths.concat(this.generateFromSubDirectories(subdirectories));
        }

        return elmPaths;
    }

    isElmProjectWithTests(dirPath) {
        return this.hasPackageJson(dirPath) && this.hasTestsSubdirectory(dirPath);
    }

    hasPackageJson(dirPath) {
        return fs.existsSync(path.join(dirPath, "elm-package.json"));
    }

    hasTestsSubdirectory(dirPath) {
        return fs.existsSync(path.join(dirPath, "tests"));
    }

    subdirectoryList(dirPath) {
        const isDirectory = source => fs.lstatSync(source).isDirectory();

        const finalDir = checkPath => checkPath.split(path.sep).pop();
        const isNotElmStuff = source => finalDir(source) !== "elm-stuff";
        const isNotNodeModules = source => finalDir(source) !== "node_modules";
        const doesNotBeginWithDot = source => finalDir(source).substr(0, 1) !== ".";

        return fs.readdirSync(dirPath)
            .map(name => path.join(dirPath, name))
            .filter(isDirectory)
            .filter(isNotElmStuff)
            .filter(isNotNodeModules)
            .filter(doesNotBeginWithDot);
    }

}

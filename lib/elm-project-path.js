'use babel';

import fs from 'fs';
import path from 'path';

export default class ElmProjectPath {

    constructor() {}

    /* ==============================
        PUBLIC
       ============================== */

    generate() {
        return this.generateFromActiveProjectSubDirectories();
    }

    /* ==============================
        PRIVATE
       ============================== */

    generateFromActiveProjectSubDirectories() {
        let projectPaths = this.currentProjectPaths();
        if (!projectPaths) { return null; }

        return this.generateFromSubDirectories(projectPaths);
    }

    generateFromSubDirectories(paths) {
        for (let i = 0; i < paths.length; i++) {
            let subdirectories = this.subdirectoryList(paths[i]);

            for (let j = 0; j < subdirectories.length; j++) {
                let subdirPath = path.join(subdirectories[j]);

                if (this.isElmProjectWithTests(subdirPath)) {
                    return subdirPath;
                }
            }

            let foundPath = this.generateFromSubDirectories(subdirectories);
            if (foundPath) { return foundPath; }
        }

        return null;
    }

    currentProjectPaths() {
        return atom.project.getPaths();
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

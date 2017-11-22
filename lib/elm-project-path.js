'use babel';

import fs from 'fs';
import path from 'path';

export default class ElmProjectPath {

    constructor() {}

    /* ==============================
        PUBLIC
       ============================== */

    generate() {
        let path = this.generateFromOpenFileAndActiveProjects();

        if (!path) {
            path = this.generateFromPackageJsonSearch();
        }

        if (!path) {
            path = this.generateFromActiveProjects();
        }

        if (!path) {
            path = this.generateFromActiveProjectSubDirectories();
        }

        return path;
    }

    /* ==============================
        PRIVATE
       ============================== */

    generateFromOpenFileAndActiveProjects() {
        let openFile = this.currentOpenFile();
        let projectPaths = this.currentProjectPaths();
        if (!openFile || !projectPaths) { return null; }

        for (let i = 0; i < projectPaths.length; i++) {
            let projectPath = projectPaths[i];
            if (openFile.indexOf(projectPath) !== -1 && this.isElmProjectWithTests(projectPath)) {
                return projectPath;
            }
        }

        return null;
    }

    generateFromPackageJsonSearch() {
        const openFile = this.currentOpenFile();
        let projectPath = openFile;

        if (projectPath) {
            while (projectPath.lastIndexOf(path.sep) !== -1) {
                let pathSeparatorIndex = projectPath.lastIndexOf(path.sep);
                let pathToCheck = projectPath.slice(0, pathSeparatorIndex);

                if (this.isElmProjectWithTests(pathToCheck)) {
                    return pathToCheck;
                }

                projectPath = pathToCheck;
            }
        }

        return null;
    }

    generateFromActiveProjects() {
        let projectPaths = this.currentProjectPaths();
        if (!projectPaths) { return null; }

        for (let i = 0; i < projectPaths.length; i++) {
            let projectPath = projectPaths[i];
            if (this.isElmProjectWithTests(projectPath)) {
                return projectPath;
            }
        }

        return null;
    }

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

    currentOpenFile() {
        let activePaneItem = atom.workspace.getActivePaneItem();

        if (activePaneItem) {
            let buffer = activePaneItem.buffer;

            if (buffer) {
                return buffer.file.path;
            }
        }

        return null;
    }

    currentProjectPaths() {
        return atom.project.getPaths();
    }

    hasPackageJson(dirPath) {
        return fs.existsSync(path.join(dirPath, "elm-package.json"));
    }

    hasTestsSubdirectory(dirPath) {
        return fs.existsSync(path.join(dirPath, "tests"));
    }

    isElmProjectWithTests(dirPath) {
        return this.hasPackageJson(dirPath) && this.hasTestsSubdirectory(dirPath);
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

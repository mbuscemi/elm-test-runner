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

        return path;
    }

    /* ==============================
        PRIVATE
       ============================== */

    generateFromOpenFileAndActiveProjects() {
        let openFile = this.currentOpenFile();
        let projectPaths = this.currentProjectPaths();

        if (!openFile || !projectPaths) {
            return null;
        }

        for (let i = 0; i < projectPaths.length; i++) {
            let projectPath = projectPaths[i];
            if (openFile.indexOf(projectPath) !== -1 && this.hasPackageJson(projectPath)) {
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

                if (this.hasPackageJson(pathToCheck)) {
                    return pathToCheck;
                }

                projectPath = pathToCheck;
            }
        }

        return null;
    }

    generateFromActiveProjects() {
        let projectPaths = this.currentProjectPaths();

        if (!projectPaths) {
            return null;
        }

        for (let i = 0; i < projectPaths.length; i++) {
            let projectPath = projectPaths[i];
            if (this.hasPackageJson(projectPath)) {
                return projectPath;
            }
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

    hasPackageJson(projectPath) {
        const packageJsonFile = "elm-package.json";
        let pathToCheck = path.join(projectPath, packageJsonFile);

        return fs.existsSync(pathToCheck);
    }

}

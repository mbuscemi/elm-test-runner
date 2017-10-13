'use babel';

import fs from 'fs'
import path from 'path'

export default class ElmProjectPath {

    constructor() {}

    currentOpenFile() {
        let activePaneItem = atom.workspace.getActivePaneItem();
        // console.log("activePaneItem", activePaneItem);

        let buffer = activePaneItem.buffer;
        // console.log("buffer", buffer);

        if (buffer) {
            // console.log("OPEN FILE FOUND: " + buffer.file.path);
            return buffer.file.path;
        } else {
            // console.log("NO FILE OPEN IN ATOM");
            return null;
        }
    }

    currentProjectPaths() {
        // console.log("KNOWN PROJECT PATHS: ", atom.project.getPaths());
        return atom.project.getPaths();
    }

    generate() {
        let path = this.generateFromActiveProjects();
        // console.log("PATH DETERMINED FROM ACTIVE FILE: ", path);

        if (!path) {
            path = this.generateFromPackageJsonSearch();
        }

        return path;
    }

    generateFromActiveProjects() {
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

        while (projectPath.lastIndexOf(path.sep) !== -1) {
            let pathSeparatorIndex = projectPath.lastIndexOf(path.sep);
            let pathToCheck = projectPath.slice(0, pathSeparatorIndex);
            // console.log("PATH TO CHECK: ", pathToCheck);

            if (this.hasPackageJson(pathToCheck)) {
                return pathToCheck;
            }

            projectPath = pathToCheck;
        }

        return null;
    }

    hasPackageJson(projectPath) {
        const packageJsonFile = "elm-package.json";
        let pathToCheck = path.join(projectPath, packageJsonFile);
        // console.log("PATH TO CHECK: ", pathToCheck);

        return fs.existsSync(pathToCheck);
    }

}

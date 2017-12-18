'use babel';

import path from 'path';

import { CompositeDisposable } from 'atom';
import { File } from 'atom';

import ElmTestRunnerView from './elm-test-runner-view';
import ElmProjectPath from './elm-project-path';
import ElmTestCommand from './elm-test-command';
import Navigation from './navigation';
import Config from './config';

import elmApp from '../elm/built/elm.js';

export default {

    config: Config,

    elmTestRunnerView: null,
    modalPanel: null,
    subscriptions: null,

    activate(state) {
        this.elmTestRunnerView = new ElmTestRunnerView(state.elmTestRunnerViewState);
        this.elm = elmApp.Main.embed(this.elmTestRunnerView.element, this.elmTestRunnerView.serialize().data);

        let elmProjectPath = new ElmProjectPath();
        this.command = new ElmTestCommand(this.elm);
        this.navigation = new Navigation(elmProjectPath);

        this.elm.ports.updateProjectDirectories.send(elmProjectPath.currentProjectPaths());
        this.elm.ports.updateTestableElmDirectories.send(elmProjectPath.generateAll());

        this.activateSubscriptions();
        this.initializeElmPorts();

        return this.elmTestRunnerView;
    },

    deserialize(state) {},

    activateSubscriptions() {
        this.subscriptions = new CompositeDisposable();

        this.subscriptions.add(atom.workspace.addOpener(uri => {
            if (uri === 'atom://elm-test-runner') {
                return this.elmTestRunnerView;
            }
        }));

        const rightDock = atom.workspace.getRightDock();
        const leftDock = atom.workspace.getLeftDock();
        const bottomDock = atom.workspace.getBottomDock();

        this.subscriptions.add(rightDock.onDidStopChangingActivePaneItem((event) => {
            if (event === this.elmTestRunnerView) {
                this.elm.ports.notifyPaneMoved.send("right");
            }
        }));

        this.subscriptions.add(leftDock.onDidStopChangingActivePaneItem((event) => {
            if (event === this.elmTestRunnerView) {
                this.elm.ports.notifyPaneMoved.send("left");
            }
        }));

        this.subscriptions.add(bottomDock.onDidStopChangingActivePaneItem((event) => {
            if (event === this.elmTestRunnerView) {
                this.elm.ports.notifyPaneMoved.send("bottom");
            }
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'elm-test-runner:toggle': () => this.toggle()
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'elm-test-runner:run-test': () => this.elm.ports.commandKeyTestStart.send(null)
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'elm-test-runner:toggle-auto-run': () => this.elm.ports.toggleAutoRun.send(null)
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'elm-test-runner:toggle-auto-navigate': () => this.elm.ports.toggleAutoNavigate.send(null)
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'elm-test-runner:toggle-elm-verify-examples': () => this.elm.ports.toggleElmVerifyExamples.send(null)
        }));

        this.subscriptions.add(atom.commands.add('atom-workspace', {
            'core:save': () => this.elm.ports.notifySaveEvent.send(null)
        }));
    },

    initializeElmPorts() {
        this.elm.ports.runTest.subscribe((data) => {
            const projectDirectory = data[0];
            const seed = data[1];
            this.runTest(projectDirectory, seed);
        });

        this.elm.ports.copySeed.subscribe((seed) => {
            atom.clipboard.write(seed);
        });

        this.elm.ports.navigateToFile.subscribe((potentialPathPiecesAndTestDescription) => {
            let potentialPathPieces = potentialPathPiecesAndTestDescription[0];
            let testDescription = potentialPathPiecesAndTestDescription[1];
            this.navigation.tryShow(potentialPathPieces, testDescription);
        });

        this.elm.ports.updatePersistentState.subscribe((newState) => {
            this.elmTestRunnerView.setState(newState);
        });
    },

    runTest(projectDirectory, seed) {
        this.elmTestRunnerView.toggleIfClosed();
        this.command.run(this.elmTestRunnerView.state.useElmVerifyExamples, projectDirectory, seed);
    },

    toggle() {
        this.elmTestRunnerView.toggle();
    },

    deactivate() {
        this.subscriptions.dispose();
        this.elmTestRunnerView.destroy();
        this.command.deactivate();
    },

    serialize() {
        return {
            elmTestRunnerViewState: this.elmTestRunnerView.serialize()
        };
    }

};

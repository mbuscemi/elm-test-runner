'use babel';

import path from 'path';

import { CompositeDisposable } from 'atom';
import { File } from 'atom';

import ElmTestRunnerView from './elm-test-runner-view';
import ElmProjectPath from './elm-project-path';
import ElmTestCommand from './elm-test-command';
import Navigation from './navigation';

import elmApp from '../elm/built/elm.js';

export default {

    elmTestRunnerView: null,
    modalPanel: null,
    subscriptions: null,

    activate(state) {
        this.elmTestRunnerView = new ElmTestRunnerView(state.elmTestRunnerViewState);

        let serializedData = JSON.stringify(this.elmTestRunnerView.serialize().data);
        this.elm = elmApp.Main.embed(this.elmTestRunnerView.element, serializedData);

        let elmProjectPath = new ElmProjectPath();
        this.command = new ElmTestCommand(this.elm, elmProjectPath);
        this.navigation = new Navigation(elmProjectPath);

        this.activateSubscriptions();
        this.initializeElmPorts();
        this.validateElmVersion();

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
            'core:save': () => this.elm.ports.notifySaveEvent.send(null)
        }));
    },

    initializeElmPorts() {
        this.elm.ports.runTest.subscribe((seed) => {
            this.runTest(seed);
        });

        this.elm.ports.copySeed.subscribe((seed) => {
            atom.clipboard.write(seed);
        });

        this.elm.ports.navigateToFile.subscribe((potentialPathPiecesAndTestDescription) => {
            let potentialPathPieces = potentialPathPiecesAndTestDescription[0];
            let testDescription = potentialPathPiecesAndTestDescription[1];

            let numPieces = potentialPathPieces.length;
            for (let i = numPieces - 1; i > 0; i--) {

                let pathToFile = "tests";
                for (j = 0; j < i; j++) {
                    pathToFile = path.join(pathToFile, potentialPathPieces[j]);
                }
                pathToFile += ".elm";

                if (this.navigation.canShow(pathToFile)) {
                    this.navigation.show(pathToFile, testDescription);
                    break;
                }

            }
        });

        this.elm.ports.updatePersistentState.subscribe((newState) => {
            this.elmTestRunnerView.setState(newState);
        });
    },

    validateElmVersion() {
        this.command.checkVersion();
    },

    runTest(seed) {
        atom.workspace.open('atom://elm-test-runner');
        this.command.run(seed);
    },

    toggle() {
        atom.workspace.toggle('atom://elm-test-runner');
    },

    deactivate() {
        this.subscriptions.dispose();
        this.elmTestRunnerView.destroy();
    },

    serialize() {
        return {
            elmTestRunnerViewState: this.elmTestRunnerView.serialize()
        };
    }

};

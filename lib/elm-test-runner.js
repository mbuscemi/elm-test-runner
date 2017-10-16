'use babel';

import { CompositeDisposable } from 'atom';

import ElmTestRunnerView from './elm-test-runner-view';
import ElmTestCommand from './elm-test-command';

import elmApp from '../elm/built/elm.js';

export default {

    elmTestRunnerView: null,
    modalPanel: null,
    subscriptions: null,

    activate(state) {
        this.elmTestRunnerView = new ElmTestRunnerView(state.elmTestRunnerViewState);
        this.elm = elmApp.Main.embed(this.elmTestRunnerView.element);

        this.command = new ElmTestCommand(this.elm);

        this.activateSubscriptions();
        this.initializeElmPorts();
        this.validateElmVersion();
    },

    activateSubscriptions() {
        this.subscriptions = new CompositeDisposable();

        this.subscriptions.add(atom.workspace.addOpener(uri => {
            if (uri === 'atom://elm-test-runner') {
                return this.elmTestRunnerView;
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
            'core:save': () => this.elm.ports.notifySaveEvent.send(null)
        }));
    },

    initializeElmPorts() {
        this.elm.ports.toggle.subscribe(() => {
            this.toggle();
        });

        this.elm.ports.runTest.subscribe((seed) => {
            this.runTest(seed);
        });

        this.elm.ports.copySeed.subscribe((seed) => {
            atom.clipboard.write(seed);
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

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

        this.modalPanel = atom.workspace.addRightPanel({
            item: this.elmTestRunnerView.getElement(),
            visible: false
        });

        this.activateSubscriptions();
        this.initializeElmPorts();
        // this.validateElmVersion();
    },

    activateSubscriptions() {
        this.subscriptions = new CompositeDisposable();

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

    runTest(seed) {
        this.command.run(seed);

        if (!this.modalPanel.isVisible()) {
            this.toggle();
        }
    },

    deactivate() {
        this.modalPanel.destroy();
        this.subscriptions.dispose();
        this.elmTestRunnerView.destroy();
    },

    serialize() {
        return {
            elmTestRunnerViewState: this.elmTestRunnerView.serialize()
        };
    },

    toggle() {
        return (
            this.modalPanel.isVisible() ?
            this.modalPanel.hide() :
            this.modalPanel.show()
        );
    }

};

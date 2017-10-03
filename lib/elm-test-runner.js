'use babel';

import ElmTestRunnerView from './elm-test-runner-view';

import { CompositeDisposable } from 'atom';
import { BufferedProcess } from 'atom';

import elmApp from '../elm/built/elm.js';

export default {

  elmTestRunnerView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.elmTestRunnerView = new ElmTestRunnerView(state.elmTestRunnerViewState);
    this.elm = elmApp.Main.embed(this.elmTestRunnerView.element);

    this.modalPanel = atom.workspace.addRightPanel({
      item: this.elmTestRunnerView.getElement(),
      visible: false
    });

    this.activateSubscriptions();
    this.initializeElmPorts();
  },

  activateSubscriptions() {
      this.subscriptions = new CompositeDisposable();

      this.subscriptions.add(atom.commands.add('atom-workspace', {
        'elm-test-runner:toggle': () => this.toggle()
      }));

      this.subscriptions.add(atom.commands.add('atom-workspace', {
        'elm-test-runner:run-test': () => this.runTest()
      }));
  },

  initializeElmPorts() {
      this.elm.ports.toggle.subscribe(() => {
          this.toggle();
      });

      this.elm.ports.runTest.subscribe(() => {
          this.runTest();
      });
  },

  runTest() {
      const command = 'elm-test';
      const args = ['--report', 'json'];
      const options = { cwd: atom.project.getPaths()[0] };

      const stdout = (output) => {
          console.log('console produced output: ', output);
          let jsonOutput = JSON.parse(output);
          console.log('parsed output: ', jsonOutput);

          if (jsonOutput.event == "runStart") {
              this.elm.ports.runStart.send(jsonOutput);
          } else if (jsonOutput.event == "testCompleted") {
              this.elm.ports.testCompleted.send(jsonOutput);
          } else if (jsonOutput.event == "runComplete") {
              this.elm.ports.runComplete.send(jsonOutput);
          } else {
              console.log("ERROR: unrecognized event type \"" + jsonOutput.event + "\"")
          }
      };

      const stderr = (error) => { console.log('found error: ', error) };
      const exit = (code) => { console.log('found code: ', code) };

      let process = new BufferedProcess({command, args, options, stdout, stderr, exit});

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

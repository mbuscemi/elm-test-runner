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
        'elm-test-runner:run-test': () => {
            this.elm.ports.commandKeyTestStart.send(null);
            this.runTest();
        }
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
      const exit = (code) => { console.log('found code: ', code) };

      const stderr = (error) => {
          this.elm.ports.notifyCompilerErrored.send(null);
          console.log('found error: ', error)
      };

      const stdout = (output) => {
        //   console.log('console produced output: ', output);

          let testJsons = output.split('\n');
        //   console.log('split JSONs: ', testJsons);

          testJsons.forEach((jsonString) => this.processTest(jsonString));
      };

      let process = new BufferedProcess({command, args, options, stdout, stderr, exit});

      if (!this.modalPanel.isVisible()) {
          this.toggle();
      }
  },

  processTest(testJsonString) {
      if (testJsonString != "") {
          let testJson = JSON.parse(testJsonString);
          console.log('parsed output: ', testJson);

          if (testJson.event == "runStart") {
              this.elm.ports.runStart.send(testJson);
          } else if (testJson.event == "testCompleted") {
              this.elm.ports.testCompleted.send(testJsonString);
          } else if (testJson.event == "runComplete") {
              this.elm.ports.runComplete.send(testJson);
          } else {
              console.log("ERROR: unrecognized event type \"" + testJson.event + "\"")
          }
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

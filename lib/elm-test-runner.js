'use babel';

import ElmTestRunnerView from './elm-test-runner-view';
import { CompositeDisposable } from 'atom';
import { BufferedProcess } from 'atom';

export default {

  elmTestRunnerView: null,
  modalPanel: null,
  subscriptions: null,
  lastTestOutput: '',

  activate(state) {
    this.elmTestRunnerView = new ElmTestRunnerView(state.elmTestRunnerViewState);

    this.modalPanel = atom.workspace.addRightPanel({
      item: this.elmTestRunnerView.getElement(),
      visible: false
    });

    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'elm-test-runner:toggle': () => this.toggle()
    }));

    const command = 'pwd';
    const args = [];
    const options = { cwd: atom.project.getPaths()[0] }
    const stdout = (output) => {
        lastTestOutput = output;
        console.log('console produced output: ', output);
    };
    const stderr = (error) => { console.log('found error: ', error) };
    const exit = (code) => { console.log('found code: ', code) };
    const process = new BufferedProcess({command, args, options, stdout, stderr, exit});

    this.runTest();
  },

  runTest() {
      const command = 'elm-test';
      const args = ['--report', 'json'];
      const options = { cwd: atom.project.getPaths()[0] }
      const stdout = (output) => {
          lastTestOutput = output;
          console.log('console produced output: ', output);
      };
      const stderr = (error) => { console.log('found error: ', error) };
      const exit = (code) => { console.log('found code: ', code) };
      const process = new BufferedProcess({command, args, options, stdout, stderr, exit});
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

'use babel';

import ElmTestRunnerView from './elm-test-runner-view';
import { CompositeDisposable } from 'atom';

export default {

  elmTestRunnerView: null,
  modalPanel: null,
  subscriptions: null,

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

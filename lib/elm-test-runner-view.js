'use babel';

import elmApp from '../elm/built/elm.js';

export default class ElmTestRunnerView {

  constructor(serializedState) {
    this.element = document.createElement('div');
    this.element.classList.add('elm-test-runner');

    const elm = elmApp.Main.embed(this.element);
  }

  serialize() {}

  destroy() {
    this.element.remove();
  }

  getElement() {
    return this.element;
  }

}

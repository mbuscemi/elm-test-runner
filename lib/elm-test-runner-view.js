'use babel';

export default class ElmTestRunnerView {

  constructor(serializedState) {
    this.element = document.createElement('div');
    this.element.classList.add('elm-test-runner');

    const title = document.createElement('div');
    title.textContent = 'Elm Test Runner';
    this.element.classList.add('title');
    this.element.appendChild(title);
  }

  serialize() {}

  destroy() {
    this.element.remove();
  }

  getElement() {
    return this.element;
  }

}

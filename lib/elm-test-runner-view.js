'use babel';

export default class ElmTestRunnerView {

    constructor(serializedState) {
        this.element = document.createElement('div');
        this.element.classList.add('elm-test-runner');
    }

    serialize() {}

    destroy() {
        this.element.remove();
    }

    getElement() {
        return this.element;
    }

}

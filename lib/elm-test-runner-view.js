'use babel';

export default class ElmTestRunnerView {

    constructor(serializedState) {
        this.element = document.createElement('div');
        this.element.classList.add('elm-test-runner');
    }

    getTitle() {
        return 'Elm Test Runner';
    }

    getIconName() {
        return 'beaker';
    }

    getDefaultLocation() {
        return 'bottom';
    }

    getAllowedLocations() {
        return ['left', 'right', 'bottom'];
    }

    getURI() {
        return 'atom://elm-test-runner';
    }

    serialize() {}

    destroy() {
        this.element.remove();
    }

    getElement() {
        return this.element;
    }

}

'use babel';

export default class ElmTestRunnerView {

    constructor(serializedState) {
        this.deserialize(serializedState);
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

    setState(newState) {
        this.state = newState;
    }

    deserialize(serializedState) {
        if (typeof serializedState !== "object") {
            this.state = {};
        } else {
            this.state = serializedState.data;
        }
    }

    serialize() {
        return {
            deserializer: 'ElmTestRunnerView',
            data: this.state
        };
    }

    destroy() {
        this.element.remove();
    }

    getElement() {
        return this.element;
    }

}

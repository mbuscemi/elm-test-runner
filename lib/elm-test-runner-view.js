'use babel';

export default class ElmTestRunnerView {

    constructor(serializedState) {
        this.deserialize(serializedState);
        this.element = document.createElement('div');
        this.element.classList.add('elm-test-runner');
        this.showing = false;
    }

    getTitle() {
        return 'Elm Test Runner';
    }

    getIconName() {
        return 'beaker';
    }

    getDefaultLocation() {
        return 'right';
    }

    getAllowedLocations() {
        return ['left', 'right', 'bottom'];
    }

    getURI() {
        return 'atom://elm-test-runner';
    }

    getElement() {
        return this.element;
    }

    isOpen() {
        return this.showing;
    }

    isClosed() {
        return !this.showing;
    }

    toggle() {
        const originalActiveItem = atom.workspace.getActivePaneItem();

        const toggleAction = atom.workspace.toggle(this.getURI());
        this.showing = !this.showing;

        toggleAction.then(() => {
            atom.workspace.open(originalActiveItem.getURI());
        });
    }

    toggleIfClosed() {
        if (this.isClosed()) {
            this.toggle();
        }
    }

    setState(newState) {
        this.state = newState;
    }

    serialize() {
        return {
            deserializer: 'ElmTestRunnerView',
            data: this.state
        };
    }

    deserialize(serializedState) {
        if (typeof serializedState !== "object") {
            this.state = {};
        } else {
            this.state = serializedState.data;
        }
    }

    destroy() {
        this.element.remove();
    }

}

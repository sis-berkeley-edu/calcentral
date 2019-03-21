import update from 'immutability-helper';

export function updateStateProperty(component, stateChanges) {
  const newState = update(component.state, stateChanges);
  component.setState(newState);
}

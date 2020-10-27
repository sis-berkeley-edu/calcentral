import { SET_CONFIG } from '../action-types';

export default function CurrentUIDReducer(state = '', action) {
  if (action.type === SET_CONFIG && action.value.uid !== undefined) {
    return action.value.uid;
  }

  return state;
}

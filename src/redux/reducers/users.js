import { combineReducers } from 'redux';

import {
  USER_AUTH_START,
  USER_AUTH_SUCCESS,
  USER_AUTH_FAILURE,
} from '../action-types';

function userAuth(state = {}, action) {
  switch (action.type) {
    case USER_AUTH_START:
      return { loadState: 'pending' };
    case USER_AUTH_SUCCESS:
      return { ...action.value, loadState: 'success' };
    case USER_AUTH_FAILURE:
      return { ...action.value, loadState: 'failure', error: action.value };
    default:
      return state;
  }
}

const userReducer = combineReducers({
  userAuth,
});

export default function UsersReducer(state = {}, action) {
  if (action.uid) {
    return { ...state, [action.uid]: userReducer(state[action.uid], action) };
  }

  return state;
}

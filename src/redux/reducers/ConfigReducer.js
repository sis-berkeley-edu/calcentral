import { SET_CONFIG } from '../action-types';

const ConfigReducer = (state = {}, action) => {
  if (action.type === SET_CONFIG) {
    return { ...state, ...action.value };
  } else {
    return state;
  }
};

export default ConfigReducer;

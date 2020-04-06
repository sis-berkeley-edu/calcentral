import {
  FETCH_HOLDS_START,
  FETCH_HOLDS_SUCCESS,
  FETCH_HOLDS_FAILURE,
} from '../action-types';

const HoldsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_HOLDS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_HOLDS_SUCCESS:
      return {
        ...state,
        holds: [...action.value],
        loaded: true,
        isLoading: false,
        error: null,
      };
    case FETCH_HOLDS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default HoldsReducer;

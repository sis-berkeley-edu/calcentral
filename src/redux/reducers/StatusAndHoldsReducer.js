import {
  FETCH_STATUS_AND_HOLDS_START,
  FETCH_STATUS_AND_HOLDS_SUCCESS,
  FETCH_STATUS_AND_HOLDS_FAILURE
} from '../actions/statusActions';

const StatusAndHoldsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_STATUS_AND_HOLDS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_STATUS_AND_HOLDS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_STATUS_AND_HOLDS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default StatusAndHoldsReducer;

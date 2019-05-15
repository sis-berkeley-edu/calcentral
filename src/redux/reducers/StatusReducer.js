import {
  FETCH_STATUS_START,
  FETCH_STATUS_SUCCESS,
  FETCH_STATUS_FAILURE
} from '../actions/statusActions';

const StatusReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_STATUS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_STATUS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_STATUS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default StatusReducer;

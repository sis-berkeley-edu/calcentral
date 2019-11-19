import {
  FETCH_SIR_STATUS_START,
  FETCH_SIR_STATUS_SUCCESS,
  FETCH_SIR_STATUS_FAILURE,
} from '../actions/sirStatusActions';

const sirStatusReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_SIR_STATUS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_SIR_STATUS_SUCCESS:
      return {
        ...state,
        ...action.value,
        loaded: true,
        isLoading: false,
        error: null,
      };
    case FETCH_SIR_STATUS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default sirStatusReducer;

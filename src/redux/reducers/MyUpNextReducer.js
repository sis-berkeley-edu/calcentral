import {
  FETCH_MY_UP_NEXT_START,
  FETCH_MY_UP_NEXT_SUCCESS,
  FETCH_MY_UP_NEXT_FAILURE,
} from '../actions/myUpNextActions';

const MyUpNextReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_MY_UP_NEXT_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_MY_UP_NEXT_SUCCESS:
      return {
        ...state,
        ...action.value,
        loaded: true,
        isLoading: false,
        error: null,
      };
    case FETCH_MY_UP_NEXT_FAILURE:
      return { ...state, loaded: true, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default MyUpNextReducer;

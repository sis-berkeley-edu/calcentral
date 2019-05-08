import {
  FETCH_ACADEMICS_START,
  FETCH_ACADEMICS_SUCCESS,
  FETCH_ACADEMICS_FAILURE
} from '../actions/academicsActions';

const AcademicsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_ACADEMICS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_ACADEMICS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_ACADEMICS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default AcademicsReducer;

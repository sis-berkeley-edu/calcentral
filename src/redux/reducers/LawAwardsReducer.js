import {
  FETCH_LAW_AWARDS_START,
  FETCH_LAW_AWARDS_SUCCESS,
  FETCH_LAW_AWARDS_FAILURE
} from '../actions/lawAwardsActions';

const AcademicsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_LAW_AWARDS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_LAW_AWARDS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_LAW_AWARDS_FAILURE:
    default:
      return state;
  }
};

export default AcademicsReducer;

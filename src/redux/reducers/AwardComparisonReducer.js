import {
  FETCH_AWARD_COMPARISON_START,
  FETCH_AWARD_COMPARISON_SUCCESS,
  FETCH_AWARD_COMPARISON_FAILURE,
} from '../actions/awardComparisonActions';

const AwardComparisonReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_AWARD_COMPARISON_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_AWARD_COMPARISON_SUCCESS:
      return {
        ...state,
        ...action.value,
        loaded: true,
        isLoading: false,
        errored: false,
      };
    case FETCH_AWARD_COMPARISON_FAILURE:
      return { ...state, loaded: true, errored: true, error: action.value };
    default:
      return state;
  }
};

export default AwardComparisonReducer;

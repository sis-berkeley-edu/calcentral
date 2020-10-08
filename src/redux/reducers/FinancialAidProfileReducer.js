import {
  FETCH_FINAID_PROFILE_START,
  FETCH_FINAID_PROFILE_SUCCESS,
  FETCH_FINAID_PROFILE_FAILURE,
} from '../action-types';

const FinancialAidProfileReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_FINAID_PROFILE_START:
      return {
        ...state,
        [action.finaidYear]: {
          isLoading: true,
          error: null
        }
      };
    case FETCH_FINAID_PROFILE_SUCCESS:
      return {
        ...state,
        [action.finaidYear]: {
          ...action.value.finaidProfile,
          loaded: true,
          isLoading: false,
          error: null
        }
      };
    case FETCH_FINAID_PROFILE_FAILURE:
      return {
        ...state,
        [action.finaidYear]: {
          isLoading: false,
          error: action.value
        }
      };
    default:
      return state;
  }
};

export default FinancialAidProfileReducer;

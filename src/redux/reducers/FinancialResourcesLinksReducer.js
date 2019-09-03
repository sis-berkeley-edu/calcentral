import {
  FETCH_FINRES_LINKS_START,
  FETCH_FINRES_LINKS_SUCCESS,
  FETCH_FINRES_LINKS_FAILURE,
} from '../actions/financialResourcesLinksActions';

const FinancialResourcesLinksReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_FINRES_LINKS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_FINRES_LINKS_SUCCESS:
      return {
        ...state,
        ...action.value,
        loaded: true,
        isLoading: false,
        error: null,
      };
    case FETCH_FINRES_LINKS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default FinancialResourcesLinksReducer;

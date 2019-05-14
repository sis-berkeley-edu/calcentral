import {
  FETCH_STANDINGS_START,
  FETCH_STANDINGS_SUCCESS,
  FETCH_STANDINGS_FAILURE
} from '../actions/standingsActions';

const StandingsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_STANDINGS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_STANDINGS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_STANDINGS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default StandingsReducer;

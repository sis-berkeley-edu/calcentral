import {
  FETCH_CAL_GRANTS_START,
  FETCH_CAL_GRANTS_SUCCESS
} from '../actions/calGrantsActions';

const CalGrantsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_CAL_GRANTS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_CAL_GRANTS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    default:
      return state;
  }
};

export default CalGrantsReducer;

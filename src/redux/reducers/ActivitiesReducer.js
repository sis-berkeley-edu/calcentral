import {
  FETCH_ACTIVITIES_START,
  FETCH_ACTIVITIES_SUCCESS,
  FETCH_ACTIVITIES_FAILURE
} from '../actions/activitiesActions';

const ActivitiesReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_ACTIVITIES_START:
      return { ...state, isLoading: true, error: null};
    case FETCH_ACTIVITIES_SUCCESS:
      return { ...state, ...action.value, isLoading: false, loaded: true, error: null };
    case FETCH_ACTIVITIES_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default ActivitiesReducer;

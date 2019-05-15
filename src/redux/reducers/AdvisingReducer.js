import {
  SET_TARGET_USER_ID,
  FETCH_APPOINTMENTS_START,
  FETCH_APPOINTMENTS_SUCCESS,
  FETCH_ADVISING_ACADEMICS_START,
  FETCH_ADVISING_ACADEMICS_SUCCESS
} from '../actions/advisingActions';

const AdvisingReducer = (state = {}, action) => {
  switch (action.type) {
    case SET_TARGET_USER_ID:
      return { ...state, userId: action.value, appointments: {}, academics: {} };
    case FETCH_APPOINTMENTS_START:
      return { ...state, appointments: { ...state.appointments, isLoading: true, error: null } };
    case FETCH_APPOINTMENTS_SUCCESS:
      return { ...state, appointments: { ...state.appointments, ...action.value, loaded: true, isLoading: false, error: null } };
    case FETCH_ADVISING_ACADEMICS_START:
      return { ...state, academics: { ...state.academics, isLoading: true, error: null } };
    case FETCH_ADVISING_ACADEMICS_SUCCESS:
      return { ...state, academics: { ...state.academics, ...action.value, loaded: true, isLoading: false, error: null } };
    default:
      return state;
  }
};

export default AdvisingReducer;

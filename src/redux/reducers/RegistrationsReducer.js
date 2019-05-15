import {
  FETCH_REGISTRATIONS_START,
  FETCH_REGISTRATIONS_SUCCESS,
  FETCH_REGISTRATIONS_FAILURE
} from '../actions/registrationsActions';

const RegistrationsReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_REGISTRATIONS_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_REGISTRATIONS_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_REGISTRATIONS_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default RegistrationsReducer;

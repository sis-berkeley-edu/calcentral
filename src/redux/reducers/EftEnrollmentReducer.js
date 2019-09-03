import {
  FETCH_EFT_ENROLLMENT_START,
  FETCH_EFT_ENROLLMENT_SUCCESS,
  FETCH_EFT_ENROLLMENT_FAILURE
} from '../actions/eftEnrollmentActions';

const EftEnrollmentReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_EFT_ENROLLMENT_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_EFT_ENROLLMENT_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_EFT_ENROLLMENT_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default EftEnrollmentReducer;

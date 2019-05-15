import {
  FETCH_PROFILE_START,
  FETCH_PROFILE_SUCCESS,
  FETCH_PROFILE_FAILURE
} from '../actions/profileActions';

const ProfileReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_PROFILE_START:
      return { ...state, isLoading: true, error: null };
    case FETCH_PROFILE_SUCCESS:
      return { ...state, ...action.value, loaded: true, isLoading: false, error: null };
    case FETCH_PROFILE_FAILURE:
      return { ...state, isLoading: false, error: action.value };
    default:
      return state;
  }
};

export default ProfileReducer;

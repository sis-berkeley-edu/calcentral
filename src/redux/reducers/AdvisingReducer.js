import {
  SET_TARGET_USER_ID,
  FETCH_APPOINTMENTS_START,
  FETCH_APPOINTMENTS_SUCCESS,
  FETCH_ADVISING_ACADEMICS_START,
  FETCH_ADVISING_ACADEMICS_SUCCESS,
  FETCH_ADVISING_STATUS_AND_HOLDS_START,
  FETCH_ADVISING_STATUS_AND_HOLDS_SUCCESS,
  FETCH_ADVISING_STATUS_AND_HOLDS_FAILURE,
} from '../action-types';

const AdvisingReducer = (
  state = { appointments: {}, academics: {}, statusAndHolds: {} },
  action
) => {
  switch (action.type) {
    case SET_TARGET_USER_ID:
      return {
        userId: action.value,
        appointments: {},
        academics: {},
        statusAndHolds: {},
      };
    case FETCH_APPOINTMENTS_START:
      return {
        ...state,
        appointments: { ...state.appointments, isLoading: true, error: null },
      };
    case FETCH_APPOINTMENTS_SUCCESS:
      return {
        ...state,
        appointments: {
          ...state.appointments,
          ...action.value,
          loaded: true,
          isLoading: false,
          error: null,
        },
      };
    case FETCH_ADVISING_ACADEMICS_START:
      return {
        ...state,
        academics: { ...state.academics, isLoading: true, error: null },
      };
    case FETCH_ADVISING_ACADEMICS_SUCCESS:
      return {
        ...state,
        academics: {
          ...state.academics,
          ...action.value,
          loaded: true,
          isLoading: false,
          error: null,
        },
      };
    case FETCH_ADVISING_STATUS_AND_HOLDS_START:
      return {
        ...state,
        statusAndHolds: {
          ...state.statusAndHolds,
          isLoading: true,
          error: null,
        },
      };
    case FETCH_ADVISING_STATUS_AND_HOLDS_SUCCESS:
      return {
        ...state,
        statusAndHolds: {
          ...state.statusAndHolds,
          ...action.value,
          loaded: true,
          isLoading: false,
          error: null,
        },
      };
    case FETCH_ADVISING_STATUS_AND_HOLDS_FAILURE:
      return {
        ...state,
        statusAndHolds: {
          ...state.statusAndHolds,
          isLoading: false,
          error: action.value,
        },
      };

    default:
      return state;
  }
};

export default AdvisingReducer;

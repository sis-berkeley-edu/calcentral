import axios from 'axios';

export const SET_TARGET_USER_ID = 'SET_TARGET_USER_ID';

export const setTargetUserId = id => ({
  type: SET_TARGET_USER_ID,
  value: id
});

export const FETCH_APPOINTMENTS_START = 'FETCH_APPOINTMENTS_START';
export const FETCH_APPOINTMENTS_SUCCESS = 'FETCH_APPOINTMENTS_SUCCESS';

export const fetchAppointmentsStart = () => ({
  type: FETCH_APPOINTMENTS_START
});

export const fetchAppointmentsSuccess = appointments => ({
  type: FETCH_APPOINTMENTS_SUCCESS,
  value: appointments
});

export const fetchAppointments = (userId) => {
  return (dispatch, getState) => {
    const {
      advising: {
        appointments = {}
      } = {}
    } = getState();

    if (appointments.loaded || appointments.isLoading) {
      return new Promise((resolve, _reject) => resolve(appointments));
    } else {
      dispatch(fetchAppointmentsStart());
      axios.get(`/api/advising/employment_appointments/${userId}`)
        .then(response => {
          dispatch(fetchAppointmentsSuccess(response.data));
        });
    }
  };
};

export const FETCH_ADVISING_ACADEMICS_START = 'FETCH_ADVISING_ACADEMICS_START';
export const FETCH_ADVISING_ACADEMICS_SUCCESS = 'FETCH_ADVISING_ACADEMICS_SUCCESS';

export const fetchAdvisingAcademicsStart = () => ({
  type: FETCH_ADVISING_ACADEMICS_START
});

export const fetchAdvisingAcademicsSuccess = student => ({
  type: FETCH_ADVISING_ACADEMICS_SUCCESS,
  value: student
});

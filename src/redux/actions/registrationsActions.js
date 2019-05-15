import axios from 'axios';

export const FETCH_REGISTRATIONS_START = 'FETCH_REGISTRATIONS_START';
export const FETCH_REGISTRATIONS_SUCCESS = 'FETCH_REGISTRATIONS_SUCCESS';
export const FETCH_REGISTRATIONS_FAILURE = 'FETCH_REGISTRATIONS_FAILURE';

export const fetchRegistrationsStart = () => ({
  type: FETCH_REGISTRATIONS_START
});

export const fetchRegistrationsSuccess = registrations =>({
  type: FETCH_REGISTRATIONS_SUCCESS,
  value: registrations
});

export const fetchRegistrationsFailure = error => ({
  type: FETCH_REGISTRATIONS_FAILURE,
  value: error
});

export const fetchRegistrations = () => {
  return (dispatch, getState) => {
    const { myRegistrations } = getState();

    if (myRegistrations.loaded || myRegistrations.isLoading) {
      return new Promise((resolve, _reject) => resolve(myRegistrations));
    } else {
      dispatch(fetchRegistrationsStart());
      return axios.get('/api/my/registrations')
        .then(({ data }) => {
          dispatch(fetchRegistrationsSuccess(data.feed.student));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchRegistrationsFailure(failure));
          }
        });
    }
  };
};

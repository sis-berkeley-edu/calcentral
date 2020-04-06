import axios from 'axios';

import {
  FETCH_EFT_ENROLLMENT_START,
  FETCH_EFT_ENROLLMENT_SUCCESS,
  FETCH_EFT_ENROLLMENT_FAILURE,
} from '../action-types';

export const fetchEftEnrollmentStart = () => ({
  type: FETCH_EFT_ENROLLMENT_START,
});

export const fetchEftEnrollmentSuccess = links => ({
  type: FETCH_EFT_ENROLLMENT_SUCCESS,
  value: links,
});

export const fetchEftEnrollmentFailure = error => ({
  type: FETCH_EFT_ENROLLMENT_FAILURE,
  value: error,
});

export const fetchEftEnrollment = () => {
  return (dispatch, getState) => {
    const { myEftEnrollment } = getState();

    if (myEftEnrollment.loaded || myEftEnrollment.isLoading) {
      return new Promise((resolve, _reject) => resolve(myEftEnrollment));
    } else {
      dispatch(fetchEftEnrollmentStart());

      return axios
        .get(`/api/my/eft_enrollment`)
        .then(response => {
          dispatch(fetchEftEnrollmentSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchEftEnrollmentFailure(failure));
          }
        });
    }
  };
};

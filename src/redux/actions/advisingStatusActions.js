import axios from 'axios';

import {
  FETCH_ADVISING_STATUS_AND_HOLDS_START,
  FETCH_ADVISING_STATUS_AND_HOLDS_SUCCESS,
  FETCH_ADVISING_STATUS_AND_HOLDS_FAILURE,
} from '../action-types';

export const fetchAdvisingStatusAndHoldsStart = () => ({
  type: FETCH_ADVISING_STATUS_AND_HOLDS_START,
});

export const fetchAdvisingStatusAndHoldsSuccess = data => ({
  type: FETCH_ADVISING_STATUS_AND_HOLDS_SUCCESS,
  value: data,
});

export const fetchAdvisingStatusAndHoldsFailure = error => ({
  type: FETCH_ADVISING_STATUS_AND_HOLDS_FAILURE,
  value: error,
});

export const fetchAdvisingStatusAndHolds = studentId => {
  return (dispatch, getState) => {
    const {
      advising: { statusAndHolds = {} },
    } = getState();

    if (statusAndHolds.loaded || statusAndHolds.isLoading) {
      return new Promise((resolve, _reject) => resolve(statusAndHolds));
    } else {
      dispatch(
        fetchAdvisingStatusAndHoldsStart({
          asAdvisor: true,
          studentId: studentId,
        })
      );

      axios
        .get(`/api/advising/academics/status_and_holds/${studentId}`)
        .then(response => {
          dispatch(fetchAdvisingStatusAndHoldsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchAdvisingStatusAndHoldsFailure(failure));
          }
        });
    }
  };
};

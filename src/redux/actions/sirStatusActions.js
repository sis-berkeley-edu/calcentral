import axios from 'axios';

import {
  FETCH_SIR_STATUS_START,
  FETCH_SIR_STATUS_SUCCESS,
  FETCH_SIR_STATUS_FAILURE,
} from '../action-types';

export const fetchSirStatusStart = () => ({
  type: FETCH_SIR_STATUS_START,
});

export const fetchSirStatusSuccess = sirStatus => ({
  type: FETCH_SIR_STATUS_SUCCESS,
  value: sirStatus,
});

export const fetchSirStatusFailure = error => ({
  type: FETCH_SIR_STATUS_FAILURE,
  value: error,
});

export const fetchSirStatus = () => {
  return (dispatch, getState) => {
    const { sirStatus } = getState();

    if (sirStatus.loaded || sirStatus.isLoading) {
      return new Promise((resolve, _reject) => resolve(sirStatus));
    } else {
      dispatch(fetchSirStatusStart());

      return axios
        .get(`/api/my/sir_statuses`)
        .then(response => {
          dispatch(fetchSirStatusSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchSirStatusFailure(failure));
          }
        });
    }
  };
};

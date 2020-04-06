import axios from 'axios';

import {
  FETCH_CAL_GRANTS_START,
  FETCH_CAL_GRANTS_SUCCESS,
  FETCH_CAL_GRANTS_FAILURE,
} from '../action-types';

export const fetchCalGrantsStart = () => ({
  type: FETCH_CAL_GRANTS_START,
});

export const fetchCalGrantsSuccess = calGrants => ({
  type: FETCH_CAL_GRANTS_SUCCESS,
  value: calGrants,
});

export const fetchCalGrantsFailure = error => ({
  type: FETCH_CAL_GRANTS_FAILURE,
  value: error,
});

export const fetchCalGrants = () => {
  return (dispatch, getState) => {
    const { myCalGrants } = getState();

    if (myCalGrants.loaded || myCalGrants.isLoading) {
      return new Promise((resolve, _reject) => resolve(myCalGrants));
    } else {
      dispatch(fetchCalGrantsStart());

      axios
        .get('/api/my/calgrant_acknowledgements')
        .then(response => {
          dispatch(fetchCalGrantsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchCalGrantsFailure(failure));
          }
        });
    }
  };
};

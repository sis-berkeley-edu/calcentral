import axios from 'axios';

// var url = '/dummy/json/academics.json';
// var url = '/dummy/json/academics_reserved_seats.json';

import {
  FETCH_ACADEMICS_START,
  FETCH_ACADEMICS_SUCCESS,
  FETCH_ACADEMICS_FAILURE,
} from '../action-types';

export const fetchAcademicsStart = () => ({
  type: FETCH_ACADEMICS_START,
});

export const fetchAcademicsSuccess = academics => ({
  type: FETCH_ACADEMICS_SUCCESS,
  value: academics,
});

export const fetchAcademicsFailure = error => ({
  type: FETCH_ACADEMICS_FAILURE,
  value: error,
});

export const fetchAcademics = () => {
  return (dispatch, getState) => {
    const { myAcademics } = getState();

    if (myAcademics.loaded || myAcademics.isLoading) {
      return new Promise((resolve, _reject) => resolve(myAcademics));
    } else {
      dispatch(fetchAcademicsStart());

      return axios
        .get('/api/my/academics')
        .then(response => {
          dispatch(fetchAcademicsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchAcademicsFailure(failure));
          }
        });
    }
  };
};

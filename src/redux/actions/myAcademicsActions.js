import axios from 'axios';

// var url = '/dummy/json/academics.json';
// var url = '/dummy/json/academics_reserved_seats.json';

import {
  FETCH_MY_ACADEMICS_START,
  FETCH_MY_ACADEMICS_SUCCESS,
  FETCH_MY_ACADEMICS_FAILURE,
} from '../action-types';

export const fetchMyAcademicsStart = () => ({
  type: FETCH_MY_ACADEMICS_START,
});

export const fetchMyAcademicsSuccess = academics => ({
  type: FETCH_MY_ACADEMICS_SUCCESS,
  value: academics,
});

export const fetchMyAcademicsFailure = error => ({
  type: FETCH_MY_ACADEMICS_FAILURE,
  value: error,
});

export const fetchMyAcademics = () => {
  return (dispatch, getState) => {
    const { myAcademics } = getState();

    if (myAcademics.loaded || myAcademics.isLoading) {
      return new Promise((resolve, _reject) => resolve(myAcademics));
    } else {
      dispatch(fetchMyAcademicsStart());

      return axios
        .get('/api/my/academics')
        .then(response => {
          dispatch(fetchMyAcademicsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchMyAcademicsFailure(failure));
          }
        });
    }
  };
};

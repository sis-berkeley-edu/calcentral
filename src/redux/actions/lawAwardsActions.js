import axios from 'axios';

import {
  FETCH_LAW_AWARDS_START,
  FETCH_LAW_AWARDS_SUCCESS,
  FETCH_LAW_AWARDS_FAILURE,
} from '../action-types';

export const fetchLawAwardsStart = () => ({
  type: FETCH_LAW_AWARDS_START,
});

export const fetchLawAwardsSuccess = lawAwards => ({
  type: FETCH_LAW_AWARDS_SUCCESS,
  value: lawAwards,
});

export const fetchLawAwardsFailure = error => ({
  type: FETCH_LAW_AWARDS_FAILURE,
  value: error,
});

export const fetchLawAwards = () => {
  return (dispatch, getState) => {
    const { myLawAwards } = getState();

    if (myLawAwards.loaded || myLawAwards.isLoading) {
      return new Promise((resolve, _reject) => resolve(myLawAwards));
    } else {
      dispatch(fetchLawAwardsStart());

      axios
        .get('/api/my/law_awards')
        .then(({ data }) => {
          dispatch(fetchLawAwardsSuccess(data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchLawAwardsFailure(failure));
          }
        });
    }
  };
};

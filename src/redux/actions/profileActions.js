import axios from 'axios';

import {
  FETCH_PROFILE_START,
  FETCH_PROFILE_SUCCESS,
  FETCH_PROFILE_FAILURE,
} from '../action-types';

export const fetchProfileStart = () => ({
  type: FETCH_PROFILE_START,
});

export const fetchProfileSuccess = profile => ({
  type: FETCH_PROFILE_SUCCESS,
  value: profile,
});

export const fetchProfileFailure = error => ({
  type: FETCH_PROFILE_FAILURE,
  value: error,
});

export const fetchProfile = () => {
  return (dispatch, getState) => {
    const { myProfile } = getState();

    if (myProfile.loaded || myProfile.isLoading) {
      return new Promise((resolve, _reject) => resolve(myProfile));
    } else {
      dispatch(fetchProfileStart());
      return axios
        .get('/api/my/profile')
        .then(({ data }) => {
          dispatch(fetchProfileSuccess(data.feed));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchProfileFailure(failure));
          }
        });
    }
  };
};

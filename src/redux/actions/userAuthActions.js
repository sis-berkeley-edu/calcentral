import axios from 'axios';

import {
  USER_AUTH_START,
  USER_AUTH_SUCCESS,
  USER_AUTH_FAILURE,
} from '../action-types';

const fetchUserAuthStart = uid => ({ type: USER_AUTH_START, uid: uid });

const fetchUserAuthSuccess = (uid, data) => ({
  type: USER_AUTH_SUCCESS,
  uid: uid,
  value: data,
});

const fetchUserAuthFailure = (uid, error) => ({
  type: USER_AUTH_FAILURE,
  value: error,
});

export function getUserAuth(uid) {
  return (dispatch, getState) => {
    const { users } = getState();
    const { userAuth = {} } = users[uid] || {};

    if (userAuth.loadState === 'success') {
      return new Promise((resolve, _reject) => resolve(userAuth));
    } else if (userAuth.loadState !== 'pending') {
      dispatch(fetchUserAuthStart(uid));

      return axios
        .get(`/api/${uid}/user_auth`)
        .then(({ data }) => dispatch(fetchUserAuthSuccess(uid, data)))
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchUserAuthFailure(uid, failure));
          }
        });
    }
  };
}

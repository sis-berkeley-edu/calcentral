import axios from 'axios';

export const FETCH_PROFILE_START = 'FETCH_PROFILE_START';
export const FETCH_PROFILE_SUCCESS = 'FETCH_PROFILE_SUCCESS';
export const FETCH_PROFILE_FAILURE = 'FETCH_PROFILE_FAILURE';

export const fetchProfileStart = () => ({
  type: FETCH_PROFILE_START
});

export const fetchProfileSuccess = profile => ({
  type: FETCH_PROFILE_SUCCESS,
  value: profile
});

export const fetchProfileFailure = error => ({
  type: FETCH_PROFILE_FAILURE,
  value: error
});

export const fetchProfile = () => {
  return (dispatch, getState) => {
    const { myProfile } = getState();

    if (myProfile.loaded || myProfile.isLoading) {
      return new Promise((resolve, _reject) => resolve(myProfile));
    } else {
      dispatch(fetchProfileStart());
      return axios.get('/api/my/profile')
        .then(({ data }) => {
          dispatch(fetchProfileSuccess(data.feed.student));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchProfileFailure(failure));
          }
        });
    }
  };
};

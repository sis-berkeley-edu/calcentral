import axios from 'axios';

export const FETCH_HOLDS_START = 'FETCH_HOLDS_START';
export const FETCH_HOLDS_SUCCESS = 'FETCH_HOLDS_SUCCESS';
export const FETCH_HOLDS_FAILURE = 'FETCH_HOLDS_FAILURE';

export const fetchHoldsStart = () => ({
  type: FETCH_HOLDS_START
});

export const fetchHoldsSuccess = holds => ({
  type: FETCH_HOLDS_SUCCESS,
  value: holds
});

export const fetchHoldsFailure = error => ({
  type: FETCH_HOLDS_FAILURE,
  value: error
});

export const fetchHolds = () => {
  return (dispatch, getState) => {
    dispatch(fetchHoldsStart());

    const { myHolds } = getState();

    if (myHolds.loaded || myHolds.isLoaded) {
      return new Promise((resolve, _reject) => resolve(myHolds));
    } else {
      return axios.get('/api/my/holds')
        .then(({ data }) => {
          dispatch(fetchHoldsSuccess(data));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchHoldsFailure(failure));
          }
        });
    }
  };
};

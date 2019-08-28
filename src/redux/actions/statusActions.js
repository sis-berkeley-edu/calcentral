import axios from 'axios';

export const FETCH_STATUS_START = 'FETCH_STATUS_START';
export const FETCH_STATUS_SUCCESS = 'FETCH_STATUS_SUCCESS';
export const FETCH_STATUS_FAILURE = 'FETCH_STATUS_FAILURE';

export const fetchStatusStart = () => ({
  type: FETCH_STATUS_START
});

export const fetchStatusSuccess = status => ({
  type: FETCH_STATUS_SUCCESS,
  value: status
});

export const fetchStatusFailure = error => ({
  type: FETCH_STATUS_FAILURE,
  value: error
});

export const fetchStatus = () => {
  return (dispatch, getState) => {
    const { myStatus } = getState();

    if (myStatus.loaded || myStatus.isLoading) {
      return new Promise((resolve, _reject) => resolve(myStatus));
    } else {
      dispatch(fetchStatusStart());

      return axios.get('/api/my/status')
        .then(response => {
          dispatch(fetchStatusSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchStatusFailure(failure));
          }
        });
    }
  };
};

export const FETCH_STATUS_AND_HOLDS_START = 'FETCH_STATUS_AND_HOLDS_START';
export const FETCH_STATUS_AND_HOLDS_SUCCESS = 'FETCH_STATUS_AND_HOLDS_SUCCESS';
export const FETCH_STATUS_AND_HOLDS_FAILURE = 'FETCH_STATUS_AND_HOLDS_FAILURE';

export const fetchStatusAndHoldsStart = () => ({
  type: FETCH_STATUS_AND_HOLDS_START
});

export const fetchStatusAndHoldsSuccess = data => ({
  type: FETCH_STATUS_AND_HOLDS_SUCCESS,
  value: data
});

export const fetchStatusAndHoldsFailure = error => ({
  type: FETCH_STATUS_AND_HOLDS_FAILURE,
  value: error
});

export const fetchStatusAndHolds = () => {
  return (dispatch, getState) => {
    const { myStatusAndHolds } = getState();

    if (myStatusAndHolds.loaded || myStatusAndHolds.isLoading) {
      return new Promise((resolve, _reject) => resolve(myStatusAndHolds));
    } else {
      dispatch(fetchStatusAndHoldsStart());

      axios.get('/api/my/academics/status_and_holds')
        .then(response => {
          dispatch(fetchStatusAndHoldsSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = { status: error.response.status, statusText: error.response.statusText };
            dispatch(fetchStatusAndHoldsFailure(failure));
          }
        });
    }
  };
};

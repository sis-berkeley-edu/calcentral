import axios from 'axios';

export const FETCH_MY_UP_NEXT_START = 'FETCH_MY_UP_NEXT_START';
export const FETCH_MY_UP_NEXT_SUCCESS = 'FETCH_MY_UP_NEXT_SUCCESS';
export const FETCH_MY_UP_NEXT_FAILURE = 'FETCH_MY_UP_NEXT_FAILURE';

export const fetchMyUpNextStart = () => ({
  type: FETCH_MY_UP_NEXT_START,
});

export const fetchMyUpNextSuccess = myUpNext => ({
  type: FETCH_MY_UP_NEXT_SUCCESS,
  value: myUpNext,
});

export const fetchMyUpNextFailure = error => ({
  type: FETCH_MY_UP_NEXT_FAILURE,
  value: error,
});

export const fetchMyUpNext = () => {
  return (dispatch, getState) => {
    const { myUpNext } = getState();

    if (myUpNext.loaded || myUpNext.isLoading) {
      return new Promise((resolve, _reject) => resolve(myUpNext));
    } else {
      dispatch(fetchMyUpNextStart());
      const api_url = '/api/my/up_next';
      // const api_url = '/dummy/json/up_next.json';
      return axios
        .get(api_url)
        .then(({ data }) => {
          dispatch(fetchMyUpNextSuccess(data));
        })
        .catch(() => {
          const failure = {
            message: 'An error has occurred obtaining your calendar items.',
          };
          dispatch(fetchMyUpNextFailure(failure));
        });
    }
  };
};

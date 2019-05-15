import axios from 'axios';

export const FETCH_LAW_AWARDS_START = 'FETCH_LAW_AWARDS_START';
export const FETCH_LAW_AWARDS_SUCCESS = 'FETCH_LAW_AWARDS_SUCCESS';
export const FETCH_LAW_AWARDS_FAILURE = 'FETCH_LAW_AWARDS_FAILURE';

export const fetchLawAwardsStart = () => ({
  type: FETCH_LAW_AWARDS_START
});

export const fetchLawAwardsSuccess = lawAwards => ({
  type: FETCH_LAW_AWARDS_SUCCESS,
  value: lawAwards
});

export const fetchLawAwardsFailure = ({ response }) => ({
  type: FETCH_LAW_AWARDS_FAILURE,
  value: { status: response.status, statusText: response.statusText }
});

export const fetchLawAwards = () => {
  return (dispatch, getState) => {
    const { myLawAwards } = getState();

    if (myLawAwards.loaded || myLawAwards.isLoading) {
      return new Promise((resolve, _reject) => resolve(myLawAwards));
    } else {
      dispatch(fetchLawAwardsStart());
      return axios.get('/api/my/law_awards')
        .then(({ data }) => {
          dispatch(fetchLawAwardsSuccess(data));
        })
        .catch(error => {
          dispatch(fetchLawAwardsFailure(error));
        });
    }
  };
};

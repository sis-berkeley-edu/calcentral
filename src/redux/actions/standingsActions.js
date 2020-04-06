import axios from 'axios';

import {
  FETCH_STANDINGS_START,
  FETCH_STANDINGS_SUCCESS,
  FETCH_STANDINGS_FAILURE,
} from '../action-types';

export const fetchStandingsStart = () => ({
  type: FETCH_STANDINGS_START,
});

export const fetchStandingsSuccess = standings => ({
  type: FETCH_STANDINGS_SUCCESS,
  value: standings,
});

export const fetchStandingsFailure = error => ({
  type: FETCH_STANDINGS_FAILURE,
  value: error,
});

export const fetchStandings = () => {
  return (dispatch, getState) => {
    dispatch(fetchStandingsStart());

    const { myStandings } = getState();

    if (myStandings.loaded || myStandings.isLoading) {
      return new Promise((resolve, _reject) => resolve(myStandings));
    } else {
      axios
        .get('/api/my/standings')
        .then(({ data }) => {
          dispatch(fetchStandingsSuccess(data.feed));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchStandingsFailure(failure));
          }
        });
    }
  };
};

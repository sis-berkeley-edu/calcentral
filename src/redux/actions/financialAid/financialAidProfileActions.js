import axios from 'axios';

import {
  FETCH_FINAID_PROFILE_START,
  FETCH_FINAID_PROFILE_SUCCESS,
  FETCH_FINAID_PROFILE_FAILURE,
} from '../../action-types';

export const fetchFinancialAidProfileStart = (finaidYear) => ({
  type: FETCH_FINAID_PROFILE_START,
  finaidYear: finaidYear
});

export const fetchFinancialAidProfileSuccess = (finaidYear, data) => ({
  type: FETCH_FINAID_PROFILE_SUCCESS,
  finaidYear: finaidYear,
  value: data,
});

export const fetchFinancialAidProfileFailure = (finaidYear, error) => ({
  type: FETCH_FINAID_PROFILE_FAILURE,
  finaidYear: finaidYear,
  value: error,
});

export const fetchFinancialAidProfile = finaidYear => {
  return (dispatch, getState) => {
    const {
      financialAid: {
        profile: {
          [finaidYear]: finaidYearData = {}
        }
      }
    } = getState();

    if (finaidYearData.loaded || finaidYearData.isLoading) {
      return new Promise((resolve, _reject) => resolve(finaidYearData));
    } else {
      dispatch(fetchFinancialAidProfileStart(finaidYear));

      axios
        .get(`/api/my/finaid_profile/${finaidYear}`)
        .then(response => {
          dispatch(fetchFinancialAidProfileSuccess(finaidYear, response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchFinancialAidProfileFailure(finaidYear, failure));
          }
        });
    }
  };
};

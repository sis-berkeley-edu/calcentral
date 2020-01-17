import axios from 'axios';

export const FETCH_AWARD_COMPARISON_START = 'FETCH_AWARD_COMPARISON_START';
export const FETCH_AWARD_COMPARISON_SUCCESS = 'FETCH_AWARD_COMPARISON_SUCCESS';
export const FETCH_AWARD_COMPARISON_FAILURE = 'FETCH_AWARD_COMPARISON_FAILURE';

export const fetchAwardComparisonStart = () => ({
  type: FETCH_AWARD_COMPARISON_START,
});

export const fetchAwardComparisonSuccess = data => ({
  type: FETCH_AWARD_COMPARISON_SUCCESS,
  value: data,
});

export const fetchAwardComparisonFailure = error => ({
  type: FETCH_AWARD_COMPARISON_FAILURE,
  value: error,
});

export const fetchAwardComparison = () => {
  return (dispatch, getState) => {
    const { awardComparison } = getState();

    if (awardComparison.loaded || awardComparison.isLoading) {
      return new Promise((resolve, _reject) => resolve(awardComparison));
    } else {
      dispatch(fetchAwardComparisonStart());

      return axios
        .get('/api/my/financial_aid/award_comparison')
        .then(response => {
          dispatch(fetchAwardComparisonSuccess(response.data));
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(fetchAwardComparisonFailure(failure));
          }
        });
    }
  };
};

export const FETCH_AWARD_COMPARISON_SNAPSHOT_START =
  'FETCH_AWARD_COMPARISON_SNAPSHOT_START';
export const FETCH_AWARD_COMPARISON_SNAPSHOT_SUCCESS =
  'FETCH_AWARD_COMPARISON_SNAPSHOT_SUCCESS';
export const FETCH_AWARD_COMPARISON_SNAPSHOT_FAILURE =
  'FETCH_AWARD_COMPARISON_SNAPSHOT_FAILURE';

export const fetchAwardComparisonSnapshotStart = (aidYear, effectiveDate) => ({
  type: FETCH_AWARD_COMPARISON_SNAPSHOT_START,
  aidYear,
  effectiveDate,
});

export const fetchAwardComparisonSnapshotSuccess = (
  aidYear,
  effectiveDate,
  data
) => ({
  type: FETCH_AWARD_COMPARISON_SNAPSHOT_SUCCESS,
  aidYear,
  effectiveDate,
  value: data,
});

export const fetchAwardComparisonSnapshotFailure = (
  aidYear,
  effectiveDate,
  error
) => ({
  type: FETCH_AWARD_COMPARISON_SNAPSHOT_FAILURE,
  aidYear,
  effectiveDate,
  value: error,
});

export const fetchAwardComparisonSnapshot = (aidYear, effectiveDate) => {
  return (dispatch, getState) => {
    const { awardComparisonSnapshot: { aidYears = {} } = {} } = getState();
    const aidYearData = aidYears[aidYear] || {};
    const snapshotData = aidYearData[effectiveDate] || {};

    if (snapshotData.loaded || snapshotData.isLoading) {
      return new Promise((resolve, _reject) => resolve(snapshotData));
    } else {
      dispatch(fetchAwardComparisonSnapshotStart(aidYear, effectiveDate));

      return axios
        .get(
          `/api/my/financial_aid/award_comparison/${aidYear}/${effectiveDate}`
        )
        .then(response => {
          dispatch(
            fetchAwardComparisonSnapshotSuccess(
              aidYear,
              effectiveDate,
              response.data
            )
          );
        })
        .catch(error => {
          if (error.response) {
            const failure = {
              status: error.response.status,
              statusText: error.response.statusText,
            };
            dispatch(
              fetchAwardComparisonSnapshotFailure(
                aidYear,
                effectiveDate,
                failure
              )
            );
          }
        });
    }
  };
};

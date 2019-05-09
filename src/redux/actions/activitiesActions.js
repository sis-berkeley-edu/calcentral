export const FETCH_ACTIVITIES_START = 'FETCH_ACTIVITIES_START';
export const FETCH_ACTIVITIES_SUCCESS = 'FETCH_ACTIVITIES_SUCCESS';
export const FETCH_ACTIVITIES_FAILURE = 'FETCH_ACTIVITIES_FAILURE';

export const fetchActivitiesStart = () => ({
  type: FETCH_ACTIVITIES_START
});

export const fetchActivitiesSuccess = activities => ({
  type: FETCH_ACTIVITIES_SUCCESS,
  value: activities
});

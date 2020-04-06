import {
  FETCH_ACTIVITIES_START,
  FETCH_ACTIVITIES_SUCCESS,
  FETCH_ACTIVITIES_FAILURE,
} from '../action-types';

export const fetchActivitiesStart = () => ({
  type: FETCH_ACTIVITIES_START,
});

export const fetchActivitiesSuccess = activities => ({
  type: FETCH_ACTIVITIES_SUCCESS,
  value: activities,
});

export const fetchActivitiesFailure = error => ({
  type: FETCH_ACTIVITIES_FAILURE,
  value: error,
});

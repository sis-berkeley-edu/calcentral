import axios from 'axios';

import {
  FETCH_CARS_DATA_START,
  FETCH_CARS_DATA_SUCCESS,
  FETCH_CARS_DATA_FAILURE,
} from '../action-types';

export const fetchCarsDataStart = () => ({
  type: FETCH_CARS_DATA_START,
});

export const fetchCarsDataSuccess = data => ({
  type: FETCH_CARS_DATA_SUCCESS,
  value: data,
});

export const fetchCarsDataFailure = () => ({
  type: FETCH_CARS_DATA_FAILURE,
});

export const fetchCarsData = () => {
  return (dispatch, getState) => {
    const { carsData } = getState();

    if (carsData.loaded || carsData.isLoading) {
      return new Promise((resolve, _reject) => resolve(carsData));
    } else {
      dispatch(fetchCarsDataStart());
      axios.get(`/api/my/financials`).then(response => {
        dispatch(fetchCarsDataSuccess(response.data));
      });
    }
  };
};

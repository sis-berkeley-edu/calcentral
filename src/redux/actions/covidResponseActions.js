import buildDataActions from '../build-data-actions';

import {
  FETCH_COVID_RESPONSE_START,
  FETCH_COVID_RESPONSE_SUCCESS,
  FETCH_COVID_RESPONSE_FAILURE,
} from '../action-types';

const { loadData: fetchCovidResponse } = buildDataActions({
  url: '/api/covid_response',
  key: 'covidResponse',
  start_const: FETCH_COVID_RESPONSE_START,
  success_const: FETCH_COVID_RESPONSE_SUCCESS,
  failure_const: FETCH_COVID_RESPONSE_FAILURE,
});

export { fetchCovidResponse };

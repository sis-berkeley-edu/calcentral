import buildDataActions from '../build-data-actions';

import {
  FETCH_AGREEMENTS_START,
  FETCH_AGREEMENTS_SUCCESS,
  FETCH_AGREEMENTS_FAILURE,
} from '../action-types';

const { loadData: fetchAgreements } = buildDataActions({
  url: '/api/my/tasks/agreements',
  key: 'myAgreements',
  start_const: FETCH_AGREEMENTS_START,
  success_const: FETCH_AGREEMENTS_SUCCESS,
  failure_const: FETCH_AGREEMENTS_FAILURE,
});

export { fetchAgreements };

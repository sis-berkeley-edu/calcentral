import buildDataActions from '../../build-data-actions';

import {
  FETCH_ACADEMICS_DIPLOMA_START,
  FETCH_ACADEMICS_DIPLOMA_SUCCESS,
  FETCH_ACADEMICS_DIPLOMA_FAILURE,
} from '../../action-types';

const { loadData: fetchAcademicsDiploma } = buildDataActions({
  url: '/api/my/academics/diploma',
  key: 'academics.diploma',
  start_const: FETCH_ACADEMICS_DIPLOMA_START,
  success_const: FETCH_ACADEMICS_DIPLOMA_SUCCESS,
  failure_const: FETCH_ACADEMICS_DIPLOMA_FAILURE,
});

export { fetchAcademicsDiploma };

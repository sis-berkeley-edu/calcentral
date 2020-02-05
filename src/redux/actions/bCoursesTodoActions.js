import buildDataActions from '../build-data-actions';

import {
  FETCH_BCOURSES_TODOS_START,
  FETCH_BCOURSES_TODOS_SUCCESS,
  FETCH_BCOURSES_TODOS_FAILURE,
} from '../action-types';

const { loadData: fetchBCoursesTodos } = buildDataActions({
  url: '/api/my/tasks/b_courses_todos',
  key: 'myBCoursesTodos',
  start_const: FETCH_BCOURSES_TODOS_START,
  success_const: FETCH_BCOURSES_TODOS_SUCCESS,
  failure_const: FETCH_BCOURSES_TODOS_FAILURE,
});

export { fetchBCoursesTodos };

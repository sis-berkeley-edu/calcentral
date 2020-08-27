import { combineReducers } from 'redux';
import buildDataReducer from '../build-data-reducer';

import {
  FETCH_ACADEMICS_DIPLOMA_START,
  FETCH_ACADEMICS_DIPLOMA_SUCCESS,
  FETCH_ACADEMICS_DIPLOMA_FAILURE
} from '../action-types';

export const DiplomaReducer = buildDataReducer(
  FETCH_ACADEMICS_DIPLOMA_START,
  FETCH_ACADEMICS_DIPLOMA_SUCCESS,
  FETCH_ACADEMICS_DIPLOMA_FAILURE
);

export const AcademicsReducer = combineReducers({
  diploma: DiplomaReducer
});

export default AcademicsReducer;

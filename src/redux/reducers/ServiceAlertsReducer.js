import {
  SERVICE_ALERTS_START,
  SERVICE_ALERTS_SUCCESS,
  SERVICE_ALERTS_FAILURE,
} from '../action-types';

export default function ServiceAlertsReducer(state = {}, action) {
  switch (action.type) {
    case SERVICE_ALERTS_START:
      return { ...state, loadState: 'pending' };
    case SERVICE_ALERTS_SUCCESS:
      return { ...state, data: action.value, loadState: 'success' };
    case SERVICE_ALERTS_FAILURE:
      return { ...state, loadState: 'failure' };
    default:
      return state;
  }
}

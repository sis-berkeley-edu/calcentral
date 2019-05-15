import { SET_CURRENT_ROUTE_PROPERTIES } from '../actions/routeActions';

const RouteReducer = (state = {}, action) => {
  switch (action.type) {
    case SET_CURRENT_ROUTE_PROPERTIES:
      return { ...state, ...action.value };
    default:
      return state;
  }
};

export default RouteReducer;

import { SET_CURRENT_ROUTE_PROPERTIES } from '../action-types';

export const setCurrentRouteProperties = props => ({
  type: SET_CURRENT_ROUTE_PROPERTIES,
  value: props,
});

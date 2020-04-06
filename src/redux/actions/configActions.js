import { SET_CONFIG } from '../action-types';

export const setConfig = config => ({
  type: SET_CONFIG,
  value: config,
});

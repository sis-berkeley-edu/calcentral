import { combineReducers } from 'redux';

import FinancialAidProfileReducer from './FinancialAidProfileReducer';

export const FinancialAidReducer = combineReducers({
  profile: FinancialAidProfileReducer,
});

export default FinancialAidReducer;

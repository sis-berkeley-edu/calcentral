import { combineReducers } from 'redux';

import AcademicsReducer from './AcademicsReducer';
import StatusReducer from './StatusReducer';
import ProfileReducer from './ProfileReducer';
import TransferCreditReducer from './TransferCreditReducer';

const AppReducer = combineReducers({
  myAcademics: AcademicsReducer,
  myProfile: ProfileReducer,
  myStatus: StatusReducer,
  myTransferCredit: TransferCreditReducer
});

export default AppReducer;

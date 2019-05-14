import { combineReducers } from 'redux';

import AcademicsReducer from './AcademicsReducer';
import CalGrantsReducer from './CalGrantsReducer';
import ConfigReducer from './ConfigReducer';
import HoldsReducer from './HoldsReducer';
import StatusReducer from './StatusReducer';
import ProfileReducer from './ProfileReducer';
import RegistrationsReducer from './RegistrationsReducer';
import TransferCreditReducer from './TransferCreditReducer';
import LinksReducer from './LinksReducer';
import RouteReducer from './RouteReducer';
import StandingsReducer from './StandingsReducer';

const AppReducer = combineReducers({
  config: ConfigReducer,
  currentRoute: RouteReducer,
  links: LinksReducer,
  myAcademics: AcademicsReducer,
  myCalGrants: CalGrantsReducer,
  myHolds: HoldsReducer,
  myProfile: ProfileReducer,
  myRegistrations: RegistrationsReducer,
  myStandings: StandingsReducer,
  myStatus: StatusReducer,
  myTransferCredit: TransferCreditReducer
});

export default AppReducer;

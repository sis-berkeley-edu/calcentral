import { combineReducers } from 'redux';

import AcademicsReducer from './AcademicsReducer';
import ActivitiesReducer from './ActivitiesReducer';
import AdvisingReducer from './AdvisingReducer';
import CalGrantsReducer from './CalGrantsReducer';
import ConfigReducer from './ConfigReducer';
import HoldsReducer from './HoldsReducer';
import LawAwardsReducer from './LawAwardsReducer';
import StatusReducer from './StatusReducer';
import ProfileReducer from './ProfileReducer';
import RegistrationsReducer from './RegistrationsReducer';
import TransferCreditReducer from './TransferCreditReducer';
import LinksReducer from './LinksReducer';
import RouteReducer from './RouteReducer';
import StandingsReducer from './StandingsReducer';

const AppReducer = combineReducers({
  advising: AdvisingReducer,
  config: ConfigReducer,
  currentRoute: RouteReducer,
  links: LinksReducer,
  myAcademics: AcademicsReducer,
  myActivities: ActivitiesReducer,
  myCalGrants: CalGrantsReducer,
  myHolds: HoldsReducer,
  myLawAwards: LawAwardsReducer,
  myProfile: ProfileReducer,
  myRegistrations: RegistrationsReducer,
  myStandings: StandingsReducer,
  myStatus: StatusReducer,
  myTransferCredit: TransferCreditReducer
});

export default AppReducer;

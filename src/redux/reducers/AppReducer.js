import { combineReducers } from 'redux';

import AcademicsReducer from './AcademicsReducer';
import ActivitiesReducer from './ActivitiesReducer';
import AdvisingReducer from './AdvisingReducer';
import BillingItemsReducer from './BillingItemsReducer';
import CarsDataReducer from './CarsDataReducer';
import CalGrantsReducer from './CalGrantsReducer';
import ConfigReducer from './ConfigReducer';
import EftEnrollmentReducer from './EftEnrollmentReducer';
import FinancialResourcesLinksReducer from './FinancialResourcesLinksReducer';
import HoldsReducer from './HoldsReducer';
import LawAwardsReducer from './LawAwardsReducer';
import LinksReducer from './LinksReducer';
import ProfileReducer from './ProfileReducer';
import RegistrationsReducer from './RegistrationsReducer';
import TransferCreditReducer from './TransferCreditReducer';
import RouteReducer from './RouteReducer';
import SirStatusReducer from './SirStatusReducer';
import StandingsReducer from './StandingsReducer';
import StatusAndHoldsReducer from './StatusAndHoldsReducer';
import StatusReducer from './StatusReducer';

const AppReducer = combineReducers({
  advising: AdvisingReducer,
  config: ConfigReducer,
  currentRoute: RouteReducer,
  billingItems: BillingItemsReducer,
  carsData: CarsDataReducer,
  financialResourcesLinks: FinancialResourcesLinksReducer,
  links: LinksReducer,
  myAcademics: AcademicsReducer,
  myActivities: ActivitiesReducer,
  myCalGrants: CalGrantsReducer,
  myEftEnrollment: EftEnrollmentReducer,
  myHolds: HoldsReducer,
  myLawAwards: LawAwardsReducer,
  myProfile: ProfileReducer,
  myRegistrations: RegistrationsReducer,
  myStandings: StandingsReducer,
  myStatus: StatusReducer,
  myStatusAndHolds: StatusAndHoldsReducer,
  myTransferCredit: TransferCreditReducer,
  sirStatus: SirStatusReducer,
});

export default AppReducer;

import { combineReducers } from 'redux';

import buildDataReducer from 'redux/build-data-reducer';

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

import {
  FETCH_AGREEMENTS_START,
  FETCH_AGREEMENTS_SUCCESS,
  FETCH_AGREEMENTS_FAILURE,
  FETCH_CHECKLIST_ITEMS_START,
  FETCH_CHECKLIST_ITEMS_SUCCESS,
  FETCH_CHECKLIST_ITEMS_FAILURE,
  FETCH_WEB_MESSAGES_START,
  FETCH_WEB_MESSAGES_SUCCESS,
  FETCH_WEB_MESSAGES_FAILURE,
  FETCH_BCOURSES_TODOS_START,
  FETCH_BCOURSES_TODOS_SUCCESS,
  FETCH_BCOURSES_TODOS_FAILURE,
} from 'redux/action-types';

const myChecklistItems = buildDataReducer(
  FETCH_CHECKLIST_ITEMS_START,
  FETCH_CHECKLIST_ITEMS_SUCCESS,
  FETCH_CHECKLIST_ITEMS_FAILURE
);

const myWebMessages = buildDataReducer(
  FETCH_WEB_MESSAGES_START,
  FETCH_WEB_MESSAGES_SUCCESS,
  FETCH_WEB_MESSAGES_FAILURE
);

const myAgreements = buildDataReducer(
  FETCH_AGREEMENTS_START,
  FETCH_AGREEMENTS_SUCCESS,
  FETCH_AGREEMENTS_FAILURE
);

const myBCoursesTodos = buildDataReducer(
  FETCH_BCOURSES_TODOS_START,
  FETCH_BCOURSES_TODOS_SUCCESS,
  FETCH_BCOURSES_TODOS_FAILURE
);

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
  myBCoursesTodos,
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
  myChecklistItems,
  myWebMessages,
  myAgreements,
});

export default AppReducer;

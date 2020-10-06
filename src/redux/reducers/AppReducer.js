import { combineReducers } from 'redux';

import academics from './AcademicsReducer';
import advising from './AdvisingReducer';
import awardComparison from './AwardComparisonReducer';
import awardComparisonSnapshot from './AwardComparisonSnapshotReducer';
import billingItems from './BillingItemsReducer';
import config from './ConfigReducer';
import currentRoute from './RouteReducer';
import financialAid from './FinancialAidReducer';
import myHolds from './HoldsReducer';
import serviceAlerts from './ServiceAlertsReducer';

import {
  CarsDataReducer as carsData,
  CovidResponseReducer as covidResponse,
  FinancialResourcesLinksReducer as financialResourcesLinks,
  LinksReducer as links,
  ActivitiesReducer as myActivities,
  AgreementsReducer as myAgreements,
  BCoursesReducer as myBCoursesTodos,
  ChecklistItemsReducer as myChecklistItems,
  EftEnrollmentReducer as myEftEnrollment,
  EnrollmentsReducer as myEnrollments,
  LawAwardsReducer as myLawAwards,
  MyAcademicsReducer as myAcademics,
  ProfileReducer as myProfile,
  RegistrationsReducer as myRegistrations,
  StandingsReducer as myStandings,
  StatusAndHoldsReducer as myStatusAndHolds,
  StatusReducer as myStatus,
  TransferCreditReducer as myTransferCredit,
  MyUpNextReducer as myUpNext,
  WebMessagesReducer as myWebMessages,
  SirStatusReducer as sirStatus,
} from './DataReducers';

import currentUID from './currentUID';
import users from './users';

const AppReducer = combineReducers({
  academics,
  advising,
  awardComparison,
  awardComparisonSnapshot,
  config,
  currentRoute,
  billingItems,
  carsData,
  covidResponse,
  financialAid,
  financialResourcesLinks,
  links,
  myAcademics,
  myActivities,
  myAgreements,
  myBCoursesTodos,
  myChecklistItems,
  myEftEnrollment,
  myEnrollments,
  myHolds,
  myLawAwards,
  myProfile,
  myRegistrations,
  myStandings,
  myStatus,
  myStatusAndHolds,
  myTransferCredit,
  myUpNext,
  myWebMessages,
  serviceAlerts,
  sirStatus,
  users,
  currentUID,
});

export default AppReducer;

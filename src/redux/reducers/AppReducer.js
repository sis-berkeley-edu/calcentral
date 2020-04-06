import { combineReducers } from 'redux';

import advising from './AdvisingReducer';
import billingItems from './BillingItemsReducer';
import config from './ConfigReducer';
import currentRoute from './RouteReducer';
import myHolds from './HoldsReducer';

import {
  CarsDataReducer as carsData,
  FinancialResourcesLinksReducer as financialResourcesLinks,
  LinksReducer as links,
  AcademicsReducer as myAcademics,
  ActivitiesReducer as myActivities,
  AgreementsReducer as myAgreements,
  BCoursesReducer as myBCoursesTodos,
  ChecklistItemsReducer as myChecklistItems,
  EftEnrollmentReducer as myEftEnrollment,
  EnrollmentsReducer as myEnrollments,
  LawAwardsReducer as myLawAwards,
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

const AppReducer = combineReducers({
  advising,
  config,
  currentRoute,
  billingItems,
  carsData,
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
  sirStatus,
});

export default AppReducer;

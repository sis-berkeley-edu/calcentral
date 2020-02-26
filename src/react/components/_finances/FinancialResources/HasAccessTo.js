import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { activeRoles } from '../../../helpers/roles';
import getLink from './getLink';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  linkName: PropTypes.string,
  links: PropTypes.object,
  myAcademics: PropTypes.object,
  myStatus: PropTypes.object,
};

const hasAccessToLink = (key, roles, careers, delegate, summer) => {
  const linkAccess = {
    activateFPP: {
      roles: ['matriculated', 'registered'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    bearsFinancialSuccess: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    berkeleyInternationalOffice: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    billingFAQ: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    calStudentCentral: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    debitAccount: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    costOfAttendance: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    delegateAccess: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    directDeposit: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    directDepositEnroll: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    directDepositManage: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    dreamActApplication: {
      roles: ['student', 'applicant', 'staff', 'faculty', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    emergencyLoan: {
      roles: ['matriculated', 'registered'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    emergencyLoanApply: {
      roles: ['matriculated', 'registered'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    fafsa: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    fafsaVerify: {
      roles: ['student', 'applicant', 'staff', 'faculty', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    federalStudentLoans: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    finaidForms: {
      roles: ['student', 'applicant', 'staff', 'faculty', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    finaidOffice: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    finaidSummary: {
      roles: ['matriculated', 'registered', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    finaidSummaryDelegate: {
      roles: ['matriculated', 'registered', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    gradFinancialSupport: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    iGrad: {
      roles: ['matriculated', 'registered', 'staff', 'faculty'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    leavingCal: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    loanRepaymentCalculator: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    mealPlanBalance: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    mealPlanLearn: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    nslds: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    paymentOptions: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    stateInstitutionalLoans: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    studentAdvocateOffice: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    summerEstimator: {
      roles: ['student', 'applicant'],
      careers: ['UGRD'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    summerFees: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: true,
    },
    summerSchedule: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: true,
    },
    summerWebsite: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    summerCancelWithdraw: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: true,
    },
    tenNinetyEightT: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    tenNinetyEightTView: {
      roles: ['student'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: false,
      allowsSummerVisitor: false,
    },
    tuitionAndFees: {
      roles: ['student', 'applicant', 'exStudent'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    tuitionAndFPP: {
      roles: ['matriculated', 'registered'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    withdrawCancel: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
    workStudy: {
      roles: ['student', 'applicant', 'exStudent'],
      careers: ['UGRD', 'GRAD', 'LAW'],
      allowsDelegateAccess: true,
      allowsSummerVisitor: false,
    },
  };
  const currentLinkAccess = linkAccess[key];
  const hasPermittedRole = currentLinkAccess.roles
    ? roles.filter(value => currentLinkAccess.roles.includes(value)).length > 0
    : true;
  const hasPermittedCareer = currentLinkAccess.careers
    ? careers.filter(value => currentLinkAccess.careers.includes(value))
        .length > 0 ||
      /* Applicants or exStudents will not have a current career and may need to have the link still displayed */
      (careers.length === 0 &&
        roles.filter(value => ['applicant', 'exStudent'].includes(value))
          .length > 0)
    : true;
  const allowsDelegate =
    !delegate || (currentLinkAccess.allowsDelegateAccess && delegate)
      ? true
      : false;
  const allowsSummer = currentLinkAccess.allowsSummerVisitor && summer;

  return (
    (hasPermittedRole && hasPermittedCareer && allowsDelegate) || allowsSummer
  );
};

// HasAccessTo will only display links that are returned from Link API and accessible given
// the specified roles, careers and delegate access.
const HasAccessTo = ({
  linkNames,
  links,
  roles,
  careerCodes,
  isDelegate,
  isSummerVisitor,
  children,
}) => {
  const hasAccessToAnyLink = linkNames.some(linkName => {
    if (getLink(linkName, links)) {
      return hasAccessToLink(
        linkName,
        roles,
        careerCodes,
        isDelegate,
        isSummerVisitor
      );
    }
  });

  return hasAccessToAnyLink ? children : null;
};

HasAccessTo.propTypes = propTypes;

const mapStateToProps = ({
  financialResourcesLinks: { links = [], matriculated = false } = {},
  myStatus = {},
  myAcademics: { collegeAndLevel: { plans = [] } = {} } = {},
}) => {
  const careerCodes = plans.map(plan => plan.career.code);

  return {
    links,
    roles: activeRoles({ ...myStatus.roles, matriculated }),
    careerCodes: careerCodes,
    isDelegate: myStatus.delegateActingAsUid,
    isSummerVisitor: myStatus.academicRoles.current.summerVisitor,
  };
};

export default connect(mapStateToProps)(HasAccessTo);

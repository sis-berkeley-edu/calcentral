import React from 'react';
import PropTypes from 'prop-types';

import './Semester.scss';
import { connect } from 'react-redux';

import SemesterSections from './SemesterSections';

const propTypes = {
  semester: PropTypes.object,
  isLawStudent: PropTypes.bool
};

const SemesterRedux = ({ semester, isLawStudent }) => {
  const {
    hasEnrolledClasses: isEnrolled,
    hasWithdrawalData: hasWithdrawn,
    hasStudyProgData: hasStudyProg,
    studyProg,
    name,
    slug,
    withdrawalStatus
  } = semester;

  if (isLawStudent && hasWithdrawn) {
    return null;
  } else {
    return (
      <div className="Semester">
        <div className="Semester__header" style={{ overflow: 'hidden' }}>
          {isEnrolled && !hasWithdrawn &&
            <h4>
              <a className="cc-left" href={`/academics/semester/${slug}`}>
                {name}
              </a>
            </h4>
          }

          {(hasWithdrawn || !isEnrolled) && <h4 className="cc-left">{name}</h4>}
          {hasWithdrawn &&
            <div className="cc-left cc-academics-semester-status" style={{ marginTop: '3px' }}>
              {withdrawalStatus.withcnclTypeDescr} {withdrawalStatus.withcnclFromDate}
            </div>
          }

          {hasStudyProg &&
            <span className="cc-left cc-academics-semester-status" style={{ marginTop: '3px' }}>
              {studyProg.studyprogTypeDescr}
            </span>
          }
        </div>

        <div className="Semester__body cc-table">
          {isEnrolled && !hasWithdrawn &&
            <SemesterSections semester={semester} />
          }
        </div>
      </div>
    );
  }
};

SemesterRedux.propTypes = propTypes;

const mapStateToProps = ({ myStatus, myTransferCredit: transferCredit }) => {
  const {
    roles: {
      law: isLawStudent
    }
  } = myStatus;

  return { transferCredit, isLawStudent };
};

export default connect(mapStateToProps)(SemesterRedux);

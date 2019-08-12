import React, { Fragment } from 'react';
import { connect } from 'react-redux';

import Semester from './Semester';

const ascendingTermId = (a, b) => {
  if (a.termId > b.termId) {
    return 1;
  } else if (a.termId < b.termId){
    return -1;
  }

  return 0;
};

const Semesters = ({ semesters, hasStudentHistory }) => {
  if (semesters.length && hasStudentHistory) {
    return (
      <Fragment>
        {semesters.sort(ascendingTermId).map((semester) => (
          <Semester key={semester.slug} semester={semester}
          />
        ))}
      </Fragment>
    );
  } else {
    return null;
  }
};

const mapStateToProps = ({
  myAcademics: { semesters },
  myStatus: { hasStudentHistory }
}) => {
  return { semesters, hasStudentHistory };
};

export default connect(mapStateToProps)(Semesters);

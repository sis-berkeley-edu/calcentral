import React, { Fragment } from 'react';
import { connect } from 'react-redux';

import Semester from './Semester';

const Semesters = ({ semesters, hasStudentHistory }) => {
  if (semesters.length && hasStudentHistory) {
    return (
      <Fragment>
        {semesters.reverse().map((semester) => (
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

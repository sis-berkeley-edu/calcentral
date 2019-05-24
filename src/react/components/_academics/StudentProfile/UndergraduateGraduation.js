import { connect } from 'react-redux';

import GenericGraduation from './GenericGraduation';

const mapStateToProps = ({ myAcademics }) => {
  const {
    collegeAndLevel: {
      termsInAttendance
    } = {},
    graduation: {
      undergraduate: {
        appointmentsInGraduatingTerm = false,
        expectedGraduationTerm
      } = {}
    } = {}
  } = myAcademics;

  return {
    appointmentsInGraduatingTerm, expectedGraduationTerm, termsInAttendance
  };
};

export default connect(mapStateToProps)(GenericGraduation);

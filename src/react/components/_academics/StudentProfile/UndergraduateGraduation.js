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
        expectedGraduationTerm,
        showGraduationChecklist = false
      } = {}
    } = {}
  } = myAcademics;

  return {
    appointmentsInGraduatingTerm, expectedGraduationTerm, termsInAttendance, showGraduationChecklist
  };
};

export default connect(mapStateToProps)(GenericGraduation);

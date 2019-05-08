import { connect } from 'react-redux';

import GenericGraduation from './GenericGraduation';

const mapStateToProps = ({ myAcademics }) => {
  const {
    graduation: {
      undergraduate: {
        appointmentsInGraduatingTerm = false,
        expectedGraduationTerm = null
      } = {}
    } = {}
  } = myAcademics;

  return {
    appointmentsInGraduatingTerm, expectedGraduationTerm
  };
};

export default connect(mapStateToProps)(GenericGraduation);

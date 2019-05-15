import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  isStudent: PropTypes.bool,
  isCurrentCollegeAndLevel: PropTypes.bool
};

const StatusAsOf = ({ isStudent, isCurrentCollegeAndLevel, termName }) => {
  if (!isCurrentCollegeAndLevel && isStudent && termName) {
    return <h3>Academic status as of {termName}</h3>;
  } else {
    return null;
  }
};

StatusAsOf.propTypes = propTypes;

const mapStateToProps = ({
  myStatus: {
    roles: {
      student: isStudent
    } = {}
  } = {},
  myAcademics: {
    collegeAndLevel: {
      termName,
      isCurrent: isCurrentCollegeAndLevel
    } = {}
  } = {}
}) => ({
  isStudent, isCurrentCollegeAndLevel, termName
});

export default connect(mapStateToProps)(StatusAsOf);

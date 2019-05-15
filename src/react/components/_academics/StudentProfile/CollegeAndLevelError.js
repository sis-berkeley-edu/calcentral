import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  errored: PropTypes.bool
};

const CollegeAndLevelError = ({ errored }) => {
  if (errored) {
    return (
      <div>There was a problem reaching campus services.</div>
    );
  } else {
    return null;
  }
};

CollegeAndLevelError.propTypes = propTypes;

const mapStateToProps = ({
  myAcademics: {
    collegeAndLevel: { errored } = {}
  } = {}
}) => ({
  errored
});

export default connect(mapStateToProps)(CollegeAndLevelError);

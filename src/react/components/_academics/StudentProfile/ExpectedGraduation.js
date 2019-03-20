import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import LawGraduation from './LawGraduation';
import GenericGraduation from './GenericGraduation';

const propTypes = {
  graduation: PropTypes.object.isRequired,
  isAdvisingStudentLookup: PropTypes.bool.isRequired
};

const ExpectedGraduation = (props) => {
  return (
    <Fragment>
      <GenericGraduation {...props} />
      <LawGraduation terms={props.graduation.gradLaw.expectedGraduationTerms || []} />
    </Fragment>
  );
};

ExpectedGraduation.propTypes = propTypes;

export default ExpectedGraduation;

import React from 'react';
import PropTypes from 'prop-types';
import ReduxProvider from 'components/ReduxProvider';
import { react2angular } from 'react2angular';

import EnrollmentNotice from 'react/components/_academics/EnrollmentNotice';

const EnrollmentNoticeContainer = ({ termId }) => (
  <ReduxProvider>
    <EnrollmentNotice termId={termId} />
  </ReduxProvider>
);

EnrollmentNoticeContainer.propTypes = {
  termId: PropTypes.string.isRequired,
};

angular
  .module('calcentral.react')
  .component('enrollmentNotice', react2angular(EnrollmentNoticeContainer));

import React from 'react';
import PropTypes from 'prop-types';
import ReduxProvider from 'components/ReduxProvider';
import { react2angular } from 'react2angular';

import ClassInfoNotice from 'react/components/_academics/ClassInfoNotice';

const ClassInfoNoticeContainer = ({ termId }) => (
  <ReduxProvider>
    <ClassInfoNotice termId={termId} />
  </ReduxProvider>
);

ClassInfoNoticeContainer.propTypes = {
  termId: PropTypes.string.isRequired,
};

angular
  .module('calcentral.react')
  .component('classInfoNotice', react2angular(ClassInfoNoticeContainer));

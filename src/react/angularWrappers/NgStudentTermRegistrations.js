import React from 'react';
import { react2angular } from 'react2angular';
import ReduxProvider from 'components/ReduxProvider';
import TermRegistrationStatuses from 'react/components/_academics/StatusAndHoldsCard/TermRegistrationStatuses';

const NgStudentTermRegistrations = () => (
  <ReduxProvider>
    <TermRegistrationStatuses isAdvisor={false} />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component(
    'studentTermRegistrations',
    react2angular(NgStudentTermRegistrations)
  );

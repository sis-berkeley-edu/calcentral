import React from 'react';
import { react2angular } from 'react2angular';
import { Provider } from 'react-redux';

import store from 'Redux/store';

import TermRegistrationStatuses from '../StatusAndHoldsCard/TermRegistrationStatuses';

const TermRegistrations = ({ isAdvisor }) => {
  if (isAdvisor) {
    return (<Provider store={store}><TermRegistrationStatuses isAdvisor={true} /></Provider>);
  } else {
    return (<Provider store={store}><TermRegistrationStatuses isAdvisor={false} /></Provider>);
  }
};

const AdvisorTermRegistrations = () => (<TermRegistrations isAdvisor={true} />);
const StudentTermRegistrations = () => (<TermRegistrations />);

angular.module('calcentral.react').component('advisorTermRegistrations', react2angular(AdvisorTermRegistrations));
angular.module('calcentral.react').component('studentTermRegistrations', react2angular(StudentTermRegistrations));

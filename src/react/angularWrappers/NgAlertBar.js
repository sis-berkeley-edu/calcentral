import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { react2angular } from 'react2angular';

import ReduxProvider from 'components/ReduxProvider';

import AlertBar from 'components/AlertBar';

const NgAlertBar = () => (
  <ReduxProvider>
    <Router>
      <AlertBar />
    </Router>
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('alertBar', react2angular(NgAlertBar));

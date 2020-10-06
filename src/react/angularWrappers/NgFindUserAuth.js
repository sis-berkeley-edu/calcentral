import React from 'react';
import { react2angular } from 'react2angular';
import { BrowserRouter as Router } from 'react-router-dom';

import FindUserAuth from 'components/UserAuths/FindUserAuth';
import CSRFToken from 'components/CSRFToken';
import ReduxProvider from 'components/ReduxProvider';

const NgFindUserAuth = () => (
  <ReduxProvider>
    <Router>
      <CSRFToken />
      <FindUserAuth />
    </Router>
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('findUserAuth', react2angular(NgFindUserAuth));

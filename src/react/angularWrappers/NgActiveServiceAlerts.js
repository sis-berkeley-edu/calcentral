import React from 'react';
import { react2angular } from 'react2angular';
import ReduxProvider from 'components/ReduxProvider';
import ActiveServiceAlerts from 'components/ServiceAlerts/ActiveServiceAlerts';
import RequireAuthor from 'components/RequireAuthor'

import { BrowserRouter as Router } from 'react-router-dom';

const NgActiveServiceAlerts = () => (
  <ReduxProvider>
    <Router>
      <RequireAuthor>
        <ActiveServiceAlerts />
      </RequireAuthor>
    </Router>
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('activeServiceAlerts', react2angular(NgActiveServiceAlerts));

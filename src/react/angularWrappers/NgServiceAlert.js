import React from 'react';
import { react2angular } from 'react2angular';

import ReduxProvider from 'components/ReduxProvider';
import ServiceAlert from 'components/ServiceAlert';

function NgServiceAlert() {
  return (
    <ReduxProvider>
      <ServiceAlert />
    </ReduxProvider>
  );
}

angular
  .module('calcentral.react')
  .component('serviceAlert', react2angular(NgServiceAlert));

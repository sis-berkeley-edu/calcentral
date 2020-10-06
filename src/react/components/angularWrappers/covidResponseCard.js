import React from 'react';
import { react2angular } from 'react2angular';

import ReduxProvider from 'components/ReduxProvider';
import COVIDResponseCard from 'react/components/_dashboard/COVIDResponseCard/COVIDResponseCard';

const COVIDResponseCardContainer = () => (
  <ReduxProvider>
    <COVIDResponseCard />
  </ReduxProvider>
);

COVIDResponseCardContainer.propTypes = {};

angular
  .module('calcentral.react')
  .component('covidResponseCard', react2angular(COVIDResponseCardContainer));

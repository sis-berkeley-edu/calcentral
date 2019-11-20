import React from 'react';
import ReduxProvider from 'react/components/ReduxProvider';
import UpNextCard from './UpNextCard';
import { react2angular } from 'react2angular';

const UpNextContainer = () => {
  return (
    <ReduxProvider>
      <UpNextCard />
    </ReduxProvider>
  );
};

angular
  .module('calcentral.react')
  .component('upNextCard', react2angular(UpNextContainer));

export default UpNextContainer;

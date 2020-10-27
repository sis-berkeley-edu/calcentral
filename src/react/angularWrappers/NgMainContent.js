import React from 'react';
import { react2angular } from 'react2angular';
import ReduxProvider from 'components/ReduxProvider';
import CSRFToken from 'components/CSRFToken';
import MainContent from 'components/MainContent';

const NgMainContent = () => (
  <ReduxProvider>
    <CSRFToken />
    <MainContent />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('mainContent', react2angular(NgMainContent));

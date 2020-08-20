import React from 'react';
import { react2angular } from 'react2angular';
import { BrowserRouter as Router } from 'react-router-dom';
import ReduxProvider from 'react/components/ReduxProvider';
import ClassInformationContainer from '../_academics/ClassInformationCard/ClassInformationContainer';

const classInformationCard = () => (
  <ReduxProvider>
    <Router>
      <ClassInformationContainer />
    </Router>
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('classInformationCard', react2angular(classInformationCard));

import React from 'react';
import { react2angular } from 'react2angular';

import ConnectedNotificationsCard from './ConnectedNotificationsCard';
import ReduxProvider from 'react/components/ReduxProvider';

const NotificationsCardContainer = () => (
  <ReduxProvider>
    <ConnectedNotificationsCard />
  </ReduxProvider>
);

export default NotificationsCardContainer;

angular
  .module('calcentral.react')
  .component('notificationsCard', react2angular(NotificationsCardContainer));

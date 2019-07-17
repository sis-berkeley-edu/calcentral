import React from 'react';
import { Provider } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';
import TransactionsCard from './TransactionsCard';

const TransactionsCardContainer = () => {
  return (
    <Provider store={store}>
      <TransactionsCard />
    </Provider>
  );
};

export default TransactionsCardContainer;

angular.module('calcentral.react').component(
  'transactionsCard',
  react2angular(TransactionsCardContainer)
);

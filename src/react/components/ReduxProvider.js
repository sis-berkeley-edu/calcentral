import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';

import store from 'Redux/store';

const ReduxProvider = ({ children }) => {
  return <Provider store={store}>{children}</Provider>;
};

ReduxProvider.propTypes = {
  children: PropTypes.node,
};

export default ReduxProvider;

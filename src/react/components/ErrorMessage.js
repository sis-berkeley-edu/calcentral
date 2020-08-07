import React from 'react';
import PropTypes from 'prop-types';

import styles from './ErrorMessage.module.scss';

export default function ErrorMessage({ message }) {
  if (message) {
    return (
      <div className={styles.errorMessage}>
        <img src="/assets/images/warning.svg" />
        <div>{message}</div>
      </div>
    );
  } else {
    return null;
  }
}

ErrorMessage.propTypes = {
  message: PropTypes.string,
  error: PropTypes.object,
};

ErrorMessage.displayName = 'ErrorMessage';

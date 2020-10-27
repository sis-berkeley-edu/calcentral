import React from 'react';
import PropTypes from 'prop-types';
import styles from './SplashContainer.module.scss';

export default function SplashContainer({ children }) {
  return <div className={styles.SplashContainer}>{children}</div>;
}

SplashContainer.propTypes = {
  children: PropTypes.node,
};

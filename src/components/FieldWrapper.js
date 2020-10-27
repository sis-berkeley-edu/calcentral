import React from 'react';
import PropTypes from 'prop-types';

import styles from './FieldWrapper.module.scss';

const FieldWrapper = ({ children, type }) => {
  if (type === 'checkbox') {
    return <div className={styles.CheckboxFieldWrapper}>{children}</div>;
  }

  return <div className={styles.FieldWrapper}>{children}</div>;
};

FieldWrapper.propTypes = {
  children: PropTypes.node,
  type: PropTypes.oneOf([null, 'checkbox']),
};

export default FieldWrapper;

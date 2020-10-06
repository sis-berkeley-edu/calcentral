import React from 'react';
import PropTypes from 'prop-types';
import styles from './FormActions.module.scss';

const FormActions = ({ children }) => (
  <div className={styles.FormActions}>{children}</div>
);

FormActions.propTypes = {
  children: PropTypes.node,
};

export default FormActions;

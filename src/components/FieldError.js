import React from 'react';
import PropTypes from 'prop-types';
import { ErrorMessage } from 'formik';

import styles from './FieldError.module.scss';

export default function FieldError({ name }) {
  return (
    <ErrorMessage name={name}>
      {msg => <div className={styles.FieldError}>{msg}</div>}
    </ErrorMessage>
  );
}

FieldError.propTypes = {
  name: PropTypes.string,
};

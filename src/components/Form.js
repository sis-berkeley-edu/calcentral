import React from 'react';
import { Form as FormikForm } from 'formik';
import PropTypes from 'prop-types';

import styles from './Form.module.scss';

const Form = ({ children }) => (
  <FormikForm className={styles.Form}>{children}</FormikForm>
);

Form.propTypes = {
  children: PropTypes.node,
};

export default Form;

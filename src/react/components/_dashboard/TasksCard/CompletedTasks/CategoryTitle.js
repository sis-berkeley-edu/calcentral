import React from 'react';
import PropTypes from 'prop-types';

import styles from './CategoryTitle.module.scss';

const CategoryTitle = ({ children }) => {
  return <h4 className={styles.title}>{children}</h4>;
};

CategoryTitle.propTypes = {
  children: PropTypes.node,
};

export default CategoryTitle;

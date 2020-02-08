import React from 'react';
import PropTypes from 'prop-types';

import styles from './Category.module.scss';

const Category = ({ children, withBottomBorder }) => {
  const classNames = withBottomBorder
    ? styles.categoryWithBorder
    : styles.category;

  return <div className={classNames}>{children}</div>;
};

Category.propTypes = {
  children: PropTypes.node,
  withBottomBorder: PropTypes.bool,
};

export default Category;

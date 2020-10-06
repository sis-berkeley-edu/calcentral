import React from 'react';
import PropTypes from 'prop-types';

import styles from './Table.module.scss';

const Table = ({ children }) => (
  <table className={styles.table}>{children}</table>
);

Table.propTypes = {
  children: PropTypes.node,
};

export default Table;

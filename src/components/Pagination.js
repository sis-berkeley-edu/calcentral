import React from 'react';
import PropTypes from 'prop-types';
import styles from './Pagination.module.scss';

const Pagination = ({
  currentPage,
  setCurrentPage,
  totalPages,
  loadState,
  setLoadState,
}) => {
  return (
    <div className={styles.Pagination}>
      <button
        onClick={() => {
          setLoadState('pending');
          setCurrentPage(currentPage - 1);
        }}
        disabled={loadState === 'pending' || currentPage === 1}
      >
        Prev
      </button>

      <span className={styles.currentState}>
        {currentPage} of {totalPages}
      </span>

      <button
        onClick={() => {
          setLoadState('pending');
          setCurrentPage(currentPage + 1);
        }}
        disabled={loadState === 'pending' || currentPage >= totalPages}
      >
        Next
      </button>
    </div>
  );
};

Pagination.propTypes = {
  currentPage: PropTypes.number,
  setCurrentPage: PropTypes.func,
  totalPages: PropTypes.number,
  loadState: PropTypes.oneOf(['pending', 'success']),
  setLoadState: PropTypes.func,
};

export default Pagination;

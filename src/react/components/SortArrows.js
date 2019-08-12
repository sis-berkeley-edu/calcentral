import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import 'icons/sort-desc-active.svg';
import 'icons/sort-desc-inactive.svg';

import './SortArrows.scss';

const reverseSortOrder = (sortOrder) => sortOrder === 'DESC' ? 'ASC' : 'DESC';

const SortArrows = ({ label, column, defaultOrder, sortBy, sortOrder, setSortBy, setSortOrder }) => {
  const matching = column === sortBy;
  if (matching) {
    return (
      <span className="SortArrows" onClick={() => setSortOrder(reverseSortOrder(sortOrder))}>
        {label}

        <div className="SortArrows__arrow-group">
          { sortOrder === 'DESC'
            ? (
              <Fragment>
                <img src="/assets/images/sort-desc-inactive.svg" className="transform-y" />
                <img src="/assets/images/sort-desc-active.svg" />
              </Fragment>
            )
            : (
              <Fragment>
                <img src="/assets/images/sort-desc-active.svg" className="transform-y" />
                <img src="/assets/images/sort-desc-inactive.svg" />
              </Fragment>
            )
          }
        </div>
      </span>
    );
  } else {
    return (
      <span className="SortArrows" onClick={() => {
        setSortBy(column);
        setSortOrder(defaultOrder);
      }}>
        {label}
        <div className="SortArrows__arrow-group">
          <img src="/assets/images/sort-desc-inactive.svg" className="transform-y" />
          <img src="/assets/images/sort-desc-inactive.svg" />
        </div>
      </span>
    );
  }
};

SortArrows.propTypes = {
  label: PropTypes.string,
  column: PropTypes.string,
  defaultOrder: PropTypes.string,
  sortBy: PropTypes.string,
  sortOrder: PropTypes.string,
  setSortBy: PropTypes.func,
  setSortOrder: PropTypes.func
};

export default SortArrows;

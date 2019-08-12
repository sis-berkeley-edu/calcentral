import React from 'react';
import PropTypes from 'prop-types';

import { termFromId } from 'React/helpers/terms';

import './TermDropdown.scss';

const TermDropdown = ({ value, termIds, onChange }) => {
  const terms = termIds.map(termFromId);

  return (
    <div className="TermDropdown">
      <label>Showing</label>
      <select value={value} onChange={(e) => onChange(e.target.value)}>
        <option value="all">All Terms</option>
        {terms.map(({ id, semester, year}) => (
          <option value={id} key={id}>{semester} {year}</option>
        ))}
      </select>
    </div>
  );
};
TermDropdown.propTypes = {
  value: PropTypes.string,
  termIds: PropTypes.array.isRequired,
  onChange: PropTypes.func
};

export default TermDropdown;

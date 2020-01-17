import React from 'react';
import PropTypes from 'prop-types';

import { termFromId } from 'React/helpers/terms';

import Dropdown from '../../../../components/Dropdown';

import './TermDropdown.scss';

const TermDropdown = ({ value, termIds, onChange }) => {
  const terms = termIds.map(termFromId);

  const options = [
    { label: 'All Terms', value: 'all' },
    ...terms.map(term => ({
      value: term.id,
      label: `${term.semester} ${term.year}`,
    })),
  ];

  return (
    <div className="TermDropdown">
      <label>Showing</label>

      <Dropdown value={value} options={options} onChange={onChange} />
    </div>
  );
};
TermDropdown.propTypes = {
  value: PropTypes.string,
  termIds: PropTypes.array.isRequired,
  onChange: PropTypes.func,
};

export default TermDropdown;

import React, { useState } from 'react';
import PropTypes from 'prop-types';

import './Dropdown.scss';
import 'icons/triangle-up.svg';
import 'icons/triangle-down.svg';
import 'icons/blue-bullet.svg';
import 'icons/white-bullet.svg';

const DropdownOption = ({ option: { label, value }, onChange, selected }) => {
  const className = `Dropdown__option ${
    selected ? 'Dropdown__option--selected' : ''
  }`;

  return (
    <div className={className} onClick={() => onChange(value)}>
      {label}
    </div>
  );
};

DropdownOption.propTypes = {
  option: PropTypes.shape({
    label: PropTypes.string,
    value: PropTypes.string,
  }),
  onChange: PropTypes.func,
  selected: PropTypes.bool,
};

const Dropdown = ({ value, onChange, options }) => {
  const [active, setActive] = useState(false);
  const selected = options.find(option => value === option.value);

  const className = active ? 'Dropdown Dropdown--active' : 'Dropdown';

  return (
    <div className={className} onClick={() => setActive(!active)}>
      {active && (
        <div className="Dropdown__overlay">
          {options.map(option => (
            <DropdownOption
              key={option.value}
              option={option}
              label={option.label}
              value={option.value}
              onChange={onChange}
              selected={value === option.value}
            />
          ))}
        </div>
      )}

      {selected.label}
    </div>
  );
};

Dropdown.propTypes = {
  value: PropTypes.string,
  onChange: PropTypes.func,
  options: PropTypes.array,
};

export default Dropdown;

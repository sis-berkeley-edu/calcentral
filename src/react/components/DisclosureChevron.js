import React from 'react';
import PropTypes from 'prop-types';

import 'icons/chevron-up.svg';
import 'icons/chevron-down.svg';

const DisclosureChevron = ({ expanded, onClick }) => {
  const icon = expanded ? 'chevron-up' : 'chevron-down';

  return (
    <div className={icon} onClick={onClick}>
      <img src={`/assets/images/${icon}.svg`} />
    </div>
  );
};
DisclosureChevron.propTypes = {
  expanded: PropTypes.bool,
  onClick: PropTypes.func
};

export default DisclosureChevron;

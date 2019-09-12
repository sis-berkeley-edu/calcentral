import React from 'react';
import PropTypes from 'prop-types';

import 'icons/chevron-down-large.svg';

const DisclosureChevron = ({ expanded, onClick }) => (
  <img
    src={`/assets/images/chevron-down-large.svg`}
    style={expanded ? { transform: `scaleY(-1)` } : null }
    onClick={onClick}
  />
);

DisclosureChevron.propTypes = {
  expanded: PropTypes.bool,
  onClick: PropTypes.func
};

export default DisclosureChevron;

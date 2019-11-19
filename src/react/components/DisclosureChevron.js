import React from 'react';
import PropTypes from 'prop-types';

import 'icons/chevron-down-large.svg';

const DisclosureChevron = ({ expanded, onClick, style = {} }) => {
  const expandedStyle = expanded ? { transform: `scaleY(-1)` } : {};
  const mergedStyle = { ...style, ...expandedStyle };

  return (
    <img
      src={`/assets/images/chevron-down-large.svg`}
      style={mergedStyle}
      onClick={onClick}
    />
  );
};

DisclosureChevron.propTypes = {
  expanded: PropTypes.bool,
  onClick: PropTypes.func,
  style: PropTypes.object,
};

export default DisclosureChevron;

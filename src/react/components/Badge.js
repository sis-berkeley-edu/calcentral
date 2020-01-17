import React from 'react';
import PropTypes from 'prop-types';

const Badge = ({
  count,
  backgroundColor = '#EEEEEE',
  color = '#000000',
  style = {},
  children,
}) => {
  const defaultStyle = {
    backgroundColor: backgroundColor,
    color: color,
    borderRadius: `10px`,
    fontSize: `10px`,
    padding: `2px 8px`,
    fontWeight: `normal`,
    height: `15px`,
    display: `flex`,
    alignItems: `center`,
  };

  return (
    <span style={{ ...defaultStyle, ...style }}>
      {count} {children}
    </span>
  );
};

Badge.displayName = 'Badge';
Badge.propTypes = {
  count: PropTypes.number,
  backgroundColor: PropTypes.string,
  color: PropTypes.string,
  style: PropTypes.object,
  children: PropTypes.node,
};

export default Badge;

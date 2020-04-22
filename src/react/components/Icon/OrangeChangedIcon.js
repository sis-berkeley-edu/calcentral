import React from 'react';
import PropTypes from 'prop-types';

const OrangeChangedIcon = ({ className }) => {
  return (
    <img
      src={`/assets/images/changed-orange.svg`}
      className={className}
      role="icon"
      style={{ backgroundColor: `white` }}
    />
  );
};

OrangeChangedIcon.displayName = 'OrangeChangedIcon';
OrangeChangedIcon.propTypes = {
  className: PropTypes.string,
  // style: PropTypes.string,
};

export default OrangeChangedIcon;

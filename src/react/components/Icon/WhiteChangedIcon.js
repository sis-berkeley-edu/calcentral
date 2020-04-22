import React from 'react';
import PropTypes from 'prop-types';

import 'icons/changed-white.svg';

const WhiteChangedIcon = ({ className }) => {
  return (
    <img
      src={`/assets/images/changed-white.svg`}
      className={className}
      role="icon"
    />
  );
};

WhiteChangedIcon.displayName = 'WhiteChangedIcon';
WhiteChangedIcon.propTypes = {
  className: PropTypes.string,
};

export default WhiteChangedIcon;

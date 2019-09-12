import React from 'react';
import PropTypes from 'prop-types';

import '../../stylesheets/icons.scss';

const propTypes = {
  name: PropTypes.string.isRequired,
  color: PropTypes.string,
  style: PropTypes.oneOfType([PropTypes.object, PropTypes.string])
};

const FontAwesomeIcon = ({ name, color, style }) => {
  if (color) {
    return <i className={`fa fa-${name} cc-react-icon cc-react-icon--${color}`} style={style}></i>;
  } else {
    return <i className={`fa fa-${name}`} style={style}></i>;
  }
};

FontAwesomeIcon.propTypes = propTypes;

export default FontAwesomeIcon;

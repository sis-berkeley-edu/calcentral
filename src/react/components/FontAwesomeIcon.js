import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  name: PropTypes.string.isRequired,
  color: PropTypes.string
};

const FontAwesomeIcon = (props) => {
  if (props.color) {
    return <i className={`fa fa-${props.name} cc-icon cc-icon-${props.color}`}></i>;
  } else {
    return <i className={`fa fa-${props.name}`}></i>;
  }
};

FontAwesomeIcon.propTypes = propTypes;

export default FontAwesomeIcon;

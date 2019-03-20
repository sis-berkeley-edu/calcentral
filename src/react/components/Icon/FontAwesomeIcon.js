import React from 'react';
import PropTypes from 'prop-types';

import '../../stylesheets/icons.scss';

const propTypes = {
  name: PropTypes.string.isRequired,
  color: PropTypes.string
};

const FontAwesomeIcon = (props) => {
  if (props.color) {
    return <i className={`fa fa-${props.name} cc-react-icon cc-react-icon--${props.color}`}></i>;
  } else {
    return <i className={`fa fa-${props.name}`}></i>;
  }
};

FontAwesomeIcon.propTypes = propTypes;

export default FontAwesomeIcon;

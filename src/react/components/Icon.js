import React from 'react';
import PropTypes from 'prop-types';
import FontAwesomeIcon from './FontAwesomeIcon';
import { ICON_PRINT, ICON_GRADUATION, ICON_CERTIFICATE } from './IconTypes';

const propTypes = {
  name: PropTypes.string.isRequired
};

const Icon = (props) => {
  switch (props.name) {
    case ICON_PRINT:
      return <FontAwesomeIcon name={props.name} />;
    case ICON_GRADUATION:
      return <FontAwesomeIcon name={props.name} color='blue' />;
    case ICON_CERTIFICATE:
      return <i className="cc-icon cc-icon-blue cc-icon-ribbon"></i>;
  }
};

Icon.propTypes = propTypes;

export default Icon;

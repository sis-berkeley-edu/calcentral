import React from 'react';
import PropTypes from 'prop-types';
import FontAwesomeIcon from './FontAwesomeIcon';
import {
  ICON_CERTIFICATE,
  ICON_CHECKMARK,
  ICON_EXCLAMATION,
  ICON_GRADUATION,
  ICON_PRINT,
  ICON_TIMES_CIRCLE
} from './IconTypes';

const propTypes = {
  name: PropTypes.string.isRequired
};

const Icon = (props) => {
  switch (props.name) {
    case ICON_CHECKMARK:
      return <FontAwesomeIcon name={props.name} color='green' />;
    case ICON_EXCLAMATION:
      return <FontAwesomeIcon name={props.name} color='red' />;
    case ICON_TIMES_CIRCLE:
      return <FontAwesomeIcon name={props.name} color='red' />;
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

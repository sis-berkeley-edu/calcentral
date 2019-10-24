import React from 'react';
import PropTypes from 'prop-types';
import FontAwesomeIcon from './FontAwesomeIcon';
import {
  ICON_ARROW_RIGHT,
  ICON_CERTIFICATE,
  ICON_CHECKMARK,
  ICON_CHEVRON_DOWN,
  ICON_CHEVRON_UP,
  ICON_EXCLAMATION,
  ICON_EXCLAMATION_TRIANGLE,
  ICON_GRADUATION,
  ICON_PRINT,
  ICON_TIMES_CIRCLE,
} from './IconTypes';

const propTypes = {
  name: PropTypes.string.isRequired,
};

const Icon = props => {
  switch (props.name) {
    case ICON_ARROW_RIGHT:
      return <FontAwesomeIcon name={props.name} />;
    case ICON_CHECKMARK:
      return <FontAwesomeIcon name={props.name} color="green" />;
    case ICON_CHEVRON_DOWN:
      return <FontAwesomeIcon name={props.name} />;
    case ICON_CHEVRON_UP:
      return <FontAwesomeIcon name={props.name} />;
    case ICON_EXCLAMATION:
      return <FontAwesomeIcon name={props.name} color="red" />;
    case ICON_EXCLAMATION_TRIANGLE:
      return <FontAwesomeIcon name={props.name} color="orange" />;
    case ICON_TIMES_CIRCLE:
      return <FontAwesomeIcon name={props.name} color="red" />;
    case ICON_PRINT:
      return <FontAwesomeIcon name={props.name} />;
    case ICON_GRADUATION:
      return <FontAwesomeIcon name={props.name} color="blue" />;
    case ICON_CERTIFICATE:
      return <i className="cc-icon cc-icon-blue cc-icon-ribbon"></i>;
  }
};

Icon.propTypes = propTypes;

export default Icon;

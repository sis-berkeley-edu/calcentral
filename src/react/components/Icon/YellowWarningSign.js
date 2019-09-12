import React from 'react';
import PropTypes from 'prop-types';

import FontAwesomeIcon from './FontAwesomeIcon';
import { ICON_WARNING } from './IconTypes';

const YellowWarningSign = ({ style }) => (
  <FontAwesomeIcon name={ICON_WARNING} color='gold' style={style} />
);

YellowWarningSign.propTypes = {
  style: PropTypes.object
};

export default YellowWarningSign;

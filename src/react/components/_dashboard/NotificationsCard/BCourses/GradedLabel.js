import React from 'react';
import PropTypes from 'prop-types';

const GradedLabel = ({ style = {} }) => {
  const defaultStyle = {
    backgroundColor: `#61889E`,
    borderRadius: `2px`,
    textTransform: `uppercase`,
    fontSize: `10px`,
    color: `white`,
    padding: `2px 4px`,
    lineHeight: `15px`,
  };
  return <span style={{ ...defaultStyle, ...style }}>Graded</span>;
};

GradedLabel.displayName = 'GradedLabel';
GradedLabel.propTypes = {
  style: PropTypes.object,
};

export default GradedLabel;

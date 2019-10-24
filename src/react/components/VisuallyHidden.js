import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  children: PropTypes.node,
};

const VisuallyHidden = ({ children }) => {
  return <span className="cc-react--visually-hidden">{children}</span>;
};

VisuallyHidden.propTypes = propTypes;

export default VisuallyHidden;

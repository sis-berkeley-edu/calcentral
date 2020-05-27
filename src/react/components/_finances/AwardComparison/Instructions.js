import React from 'react';
import PropTypes from 'prop-types';

const Instructions = ({ message }) => {
  return (
    <p
      role="region"
      tabIndex="0"
      style={{ paddingTop: `15px` }}
      dangerouslySetInnerHTML={{ __html: message }}
    />
  );
};

Instructions.propTypes = {
  message: PropTypes.string,
};

export default Instructions;

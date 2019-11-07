import React from 'react';
import PropTypes from 'prop-types';

const Tasks = ({ children }) => {
  return <div className="Tasks">{children}</div>;
};

Tasks.propTypes = {
  children: PropTypes.node,
};

export default Tasks;

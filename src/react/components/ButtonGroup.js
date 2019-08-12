import React from 'react';
import PropTypes from 'prop-types';

import './ButtonGroup.scss';

export const ButtonGroup = ({children}) => (
  <div className="ButtonGroup">{children}</div>
);

ButtonGroup.propTypes = {
  children: PropTypes.node.isRequired
};

export const GroupedButton = ({active, children, onClick}) => {
  const className = active
    ? 'GroupedButton GroupedButton--active'
    : 'GroupedButton GroupedButton--inactive';

  return (
    <div className={ className } onClick={onClick}>
      {children}
    </div>
  );
};

GroupedButton.propTypes = {
  active: PropTypes.bool,
  children: PropTypes.node.isRequired,
  onClick: PropTypes.func.isRequired
};

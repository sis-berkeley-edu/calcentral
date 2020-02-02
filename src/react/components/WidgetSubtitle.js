import React from 'react';
import PropTypes from 'prop-types';

const WidgetSubtitle = ({ children }) => (
  <h3
    style={{
      backgroundColor: `#999`,
      color: `white`,
      fontSize: `12px`,
      fontWeight: `normal`,
      padding: `2px 15px`,
      margin: `0`,
    }}
  >
    {children}
  </h3>
);

WidgetSubtitle.propTypes = {
  children: PropTypes.node.isRequired,
};

export default WidgetSubtitle;

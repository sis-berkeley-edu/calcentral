import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  children: PropTypes.node,
  dangerouslySetInnerHTML: PropTypes.object
};

const StatusDisclosure = ({ children, dangerouslySetInnerHTML }) => {
  if (children) {
    return (
      <div className="DisclosureItem__StatusDisclosure">
        {children}
      </div>
    );
  } else if (dangerouslySetInnerHTML) {
    return (
      <div className="DisclosureItem__StatusDisclosure"
        dangerouslySetInnerHTML={dangerouslySetInnerHTML} />
    );
  }
};

StatusDisclosure.propTypes = propTypes;

export default StatusDisclosure;

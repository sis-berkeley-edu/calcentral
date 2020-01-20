import React from 'react';
import PropTypes from 'prop-types';

import APILink from 'react/components/APILink';

const ArchiveLink = ({ url }) => {
  const link = {
    url: url,
    name: 'Archive of Official Communications',
  };

  return (
    <div
      className="cc-text-center cc-widget-padding"
      style={{ marginBottom: `-15px` }}
    >
      <APILink {...link} />
    </div>
  );
};

ArchiveLink.propTypes = {
  url: PropTypes.string,
};

export default ArchiveLink;

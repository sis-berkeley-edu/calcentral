import React from 'react';
import PropTypes from 'prop-types';

const defaultStyles = {
  backgroundAttachment: `fixed`,
  backgroundImage: `url(/assets/images/uc_berkeley_bay_view.jpg`,
  backgroundRepeat: `no-repeat`,
  backgroundSize: `cover`,
  padding: `30px`,
};

export default function PreviewBox({ children, style = {} }) {
  return <div style={{ ...defaultStyles, ...style }}>{children}</div>;
}

PreviewBox.propTypes = {
  children: PropTypes.node,
  style: PropTypes.object,
};

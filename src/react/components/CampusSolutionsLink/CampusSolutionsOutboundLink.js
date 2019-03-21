import React from 'react';
import PropTypes from 'prop-types';

import '../../stylesheets/box_model.scss';

const CampusSolutionsOutboundLink = (props) => {
  return (
    <a href={props.linkConfig.linkUrl} title={props.linkConfig.linkHoverText} target="_blank" rel="noopener noreferrer ">
      {props.linkConfig.linkBody}
      <span className="cc-react--visually-hidden cc-react-print-hide">Opens in new window</span>
    </a>
  );
};
CampusSolutionsOutboundLink.propTypes = {
  linkConfig: PropTypes.object.isRequired
};

export default CampusSolutionsOutboundLink;

import React from 'react';
import PropTypes from 'prop-types';

const CampusSolutionsHigherDegreeCommitteeFormLink = (props) => {
  return (
    <div>
      <a href={props.linkConfig.linkUrl} title={props.linkConfig.linkHoverText}>
        {props.linkConfig.linkBody}
      </a>: {props.linkConfig.linkHoverText}
      <div className="cc-inline-block">
        <i className="fa fa-info-circle cc-icon-air-force-blue"></i>
        &nbsp;
        <a href="http://grad.berkeley.edu/sis/tutorial" target="_blank" title="How to use the Higher Degree Committees Form" rel="noopener noreferrer">
          How to use the Higher Degree Committees Form
        </a>
      </div>
    </div>
  );
};
CampusSolutionsHigherDegreeCommitteeFormLink.propTypes = {
  linkConfig: PropTypes.object.isRequired
};

export default CampusSolutionsHigherDegreeCommitteeFormLink;

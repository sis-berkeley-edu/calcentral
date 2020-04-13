import React from 'react';
import PropTypes from 'prop-types';

const CampusSolutionsLink = (props) => {
  return (
    <a href={props.linkConfig.linkUrl} title={props.linkConfig.linkHoverText} onClick={props.onClickHandler}>
      {props.linkConfig.linkBody}
    </a>
  );
};
CampusSolutionsLink.propTypes = {
  linkConfig: PropTypes.object.isRequired,
  onClickHandler: PropTypes.func
};

export default CampusSolutionsLink;

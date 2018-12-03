import React from 'react';
import PropTypes from 'prop-types';

class CampusSolutionsOutboundLink extends React.Component {
  render() {
    return (
      <a className="cc-outbound-link" href={this.props.linkConfig.linkUrl} title={this.props.linkConfig.linkHoverText} target="_blank" rel="noopener noreferrer ">
        {this.props.linkConfig.linkBody}
        <span className="cc-outbound-link cc-visuallyhidden cc-print-hide">Opens in new window</span>
      </a>
    );
  }
}
CampusSolutionsOutboundLink.propTypes = {
  linkConfig: PropTypes.object.isRequired
};

export default CampusSolutionsOutboundLink;

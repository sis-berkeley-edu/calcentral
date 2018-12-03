import React from 'react';
import PropTypes from 'prop-types';

class CampusSolutionsLink extends React.Component {
  render() {
    return (
      <a href={this.props.linkConfig.linkUrl} title={this.props.linkConfig.linkHoverText}>
        {this.props.linkConfig.linkBody}
      </a>
    );
  }
}
CampusSolutionsLink.propTypes = {
  linkConfig: PropTypes.object.isRequired
};

export default CampusSolutionsLink;

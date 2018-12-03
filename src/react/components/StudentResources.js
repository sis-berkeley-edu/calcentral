import React from 'react';
import PropTypes from 'prop-types';

import WidgetContainer from '../containers/base/widget/WidgetContainer';

class StudentResources extends React.Component {
  render() {
    return (
      <WidgetContainer config={{...this.props.widgetConfig}}>
        {this.props.resources.map(resource => this.props.renderLinkSection(resource))}
      </WidgetContainer>
    );
  }
}
StudentResources.propTypes = {
  renderLinkSection: PropTypes.func.isRequired,
  resources: PropTypes.array.isRequired,
  widgetConfig: PropTypes.object.isRequired
};

export default StudentResources;

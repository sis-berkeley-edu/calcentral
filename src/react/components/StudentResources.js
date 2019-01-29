import React from 'react';
import PropTypes from 'prop-types';

import ListHeader from '../components/base/list/ListHeader';
import WidgetContainer from '../containers/base/widget/WidgetContainer';

class StudentResources extends React.Component {
  render() {
    return (
      <WidgetContainer config={{...this.props.widgetConfig}}>
        {this.props.resources.map(resource => this.props.renderLinkSection(resource))}
        <ListHeader header="Financial Aid Forms" />
        <p>Financial aid forms can be found in My Finances under Financial Resources</p>
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

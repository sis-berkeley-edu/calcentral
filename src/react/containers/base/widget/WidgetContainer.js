import React from 'react';
import PropTypes from 'prop-types';

import Widget from '../../../components/base/widget/Widget';

class WidgetContainer extends React.Component {
  constructor(props) {
    super(props);
    this.renderWidget = this.renderWidget.bind(this);
  }
  renderWidget() {
    // If a config object is passed without a `visible` property, default it to true.
    const visible = this.props.config.hasOwnProperty('visible') ? this.props.config.visible : true;
    if (visible) {
      return (
        <Widget config={{...this.props.config}}>
          {this.props.children}
        </Widget>
      );
    } else {
      return;
    }
  }
  render() {
    return (
      <div>
        {this.renderWidget()}
      </div>
    );
  }
}
WidgetContainer.propTypes = {
  children: PropTypes.node.isRequired,
  config: PropTypes.object.isRequired
};

export default WidgetContainer;

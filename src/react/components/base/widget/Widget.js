import React from 'react';
import PropTypes from 'prop-types';

import WidgetHeader from './WidgetHeader';
import WidgetBody from './WidgetBody';

class Widget extends React.Component {
  render() {
    return (
      <div className="cc-widget">
        <WidgetHeader title={this.props.config.title} />
        <WidgetBody errored={this.props.config.errored} errorMessage={this.props.config.errorMessage} isLoading={this.props.config.isLoading}>
          {this.props.children}
        </WidgetBody>
      </div>
    );
  }
}
Widget.propTypes = {
  children: PropTypes.node.isRequired,
  config: PropTypes.object.isRequired
};

export default Widget;

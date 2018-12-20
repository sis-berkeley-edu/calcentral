import React from 'react';
import PropTypes from 'prop-types';

import Widget from '../../../components/base/widget/Widget';
import WidgetBody from '../../../components/base/widget/WidgetBody';
import ErrorMessage from '../../../components/base/ErrorMessage';
import SpinnerContainer from '../SpinnerContainer';

class WidgetContainer extends React.Component {
  constructor(props) {
    super(props);
    this.renderWidget = this.renderWidget.bind(this);
    this.renderWidgetBody = this.renderWidgetBody.bind(this);
  }
  renderWidget() {
    // If a config object is passed without a `visible` property, default it to true.
    const visible = this.props.config.hasOwnProperty('visible') ? this.props.config.visible : true;
    if (visible) {
      return (
        <Widget config={{...this.props.config}} renderWidgetBody={this.renderWidgetBody}>
          {this.props.children}
        </Widget>
      );
    } else {
      return;
    }
  }
  renderWidgetBody() {
    if (this.props.config.errored) {
      return <ErrorMessage errorMessage={this.props.config.errorMessage} />;
    } else if (this.props.config.isLoading) {
      return <SpinnerContainer isLoadingMessage={this.props.config.isLoadingMessage} />;
    } else {
      return (
        <WidgetBody padding={this.props.config.padding}>
          {this.props.children}
        </WidgetBody>
      );
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

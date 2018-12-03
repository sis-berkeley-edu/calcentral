import PropTypes from 'prop-types';
import React from 'react';

import ErrorMessageContainer from '../../../containers/base/ErrorMessageContainer';
import SpinnerContainer from '../../../containers/base/SpinnerContainer';

class WidgetBody extends React.Component {
  render() {
    return (
      <div className="cc-widget-padding">
        <SpinnerContainer isLoading={this.props.isLoading} message={this.props.isLoadingMessage}>
          <ErrorMessageContainer errored={this.props.errored} errorMessage={this.props.errorMessage}>
            {this.props.children}
          </ErrorMessageContainer>
        </SpinnerContainer>
      </div>
    );
  }
}
WidgetBody.propTypes = {
  children: PropTypes.node.isRequired,
  errored: PropTypes.bool.isRequired,
  errorMessage: PropTypes.string.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isLoadingMessage: PropTypes.string
};

export default WidgetBody;

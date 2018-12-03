import PropTypes from 'prop-types';
import React from 'react';

class ErrorMessageContainer extends React.Component {
  constructor(props) {
    super(props);
    this.buildErrorMessage = this.buildErrorMessage.bind(this);
  }
  buildErrorMessage(message) {
    return (
      <div>{message}</div>
    );
  }
  render() {
    return (
      <div>
        {this.props.errored ? this.buildErrorMessage(this.props.errorMessage) : this.props.children}
      </div>
    );
  }
}
ErrorMessageContainer.propTypes = {
  children: PropTypes.node.isRequired,
  errored: PropTypes.bool.isRequired,
  errorMessage: PropTypes.string.isRequired
};

export default ErrorMessageContainer;

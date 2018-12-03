import PropTypes from 'prop-types';
import React from 'react';

class ErrorMessage extends React.Component {
  render() {
    return (
      <div>
        <p>{this.props.errorMessage}</p>
      </div>
    );
  }
}
ErrorMessage.propTypes = {
  errorMessage: PropTypes.string.isRequired
};

export default ErrorMessage;

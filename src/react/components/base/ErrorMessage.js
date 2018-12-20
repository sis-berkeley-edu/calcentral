import PropTypes from 'prop-types';
import React from 'react';

import '../../stylesheets/widgets.scss';

class ErrorMessage extends React.Component {
  render() {
    return (
      <div className="cc-react-widget-padding">
        {this.props.errorMessage}
      </div>
    );
  }
}
ErrorMessage.propTypes = {
  errorMessage: PropTypes.string.isRequired
};

export default ErrorMessage;

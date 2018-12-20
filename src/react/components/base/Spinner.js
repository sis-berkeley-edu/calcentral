import React from 'react';
import PropTypes from 'prop-types';

import '../../stylesheets/widgets.scss';
import '../../stylesheets/spinners.scss';
class Spinner extends React.Component {
  render() {
    return (
      <div className='cc-react-widget-padding'>
        <div aria-live="polite" className="cc-react-spinner"></div>
        { this.props.isLoadingMessage ? this.buildMessage(this.props.isLoadingMessage) : null }
      </div>
    );
  }
}
Spinner.propTypes = {
  buildMessage: PropTypes.func.isRequired,
  isLoadingMessage: PropTypes.string
};

export default Spinner;

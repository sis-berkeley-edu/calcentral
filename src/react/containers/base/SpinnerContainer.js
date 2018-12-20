import React from 'react';
import PropTypes from 'prop-types';
import Spinner from '../../components/base/Spinner';

class SpinnerContainer extends React.Component {
  constructor(props) {
    super(props);
    this.buildMessage = this.buildMessage.bind(this);
  }
  buildMessage(message) {
    return (
      <p className="cc-react-spinner-message">{message}</p>
    );
  }
  render() {
    return (
      <div>
        <Spinner buildMessage={this.buildMessage} isLoadingMessage={this.props.isLoadingMessage} />
      </div>
    );
  }
}
SpinnerContainer.propTypes = {
  isLoadingMessage: PropTypes.string
};

export default SpinnerContainer;

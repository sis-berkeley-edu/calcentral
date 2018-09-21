import React from 'react';
import PropTypes from 'prop-types';
import Spinner from '../../components/base/Spinner';

class SpinnerContainer extends React.Component {
  constructor(props) {
    super(props);
    this.buildMessage = this.buildMessage.bind(this);
    this.returnChildComponents = this.returnChildComponents.bind(this);
    this.returnSpinner = this.returnSpinner.bind(this);
  }
  buildMessage(message) {
    return (
      <p className="cc-spinner-message">{message}</p>
    );
  }
  returnChildComponents() {
    return (
      <div>{ this.props.children }</div>
    );
  }
  returnSpinner() {
    return (
      <div>
        <Spinner />
        { this.props.isLoadingMessage ? this.buildMessage(this.props.isLoadingMessage) : null }
      </div>
    );
  }
  render() {
    return this.props.isLoading ? this.returnSpinner() : this.returnChildComponents();
  }
}
SpinnerContainer.propTypes = {
  children: PropTypes.node.isRequired,
  isLoading: PropTypes.bool.isRequired,
  isLoadingMessage: PropTypes.string
};

export default SpinnerContainer;

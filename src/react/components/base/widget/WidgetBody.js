import PropTypes from 'prop-types';
import React from 'react';

import '../../../stylesheets/widgets.scss';

class WidgetBody extends React.Component {
  constructor(props) {
    super(props);
    this.renderPaddingClass = this.renderPaddingClass.bind(this);
  }
  renderPaddingClass() {
    return this.props.padding ? 'cc-react-widget-padding' : '';
  }
  render() {
    return (
      <div className={this.renderPaddingClass()}>
        {this.props.children}
      </div>
    );
  }
}
WidgetBody.defaultProps = {
  padding: true
};
WidgetBody.propTypes = {
  children: PropTypes.node.isRequired,
  padding: PropTypes.bool
};

export default WidgetBody;

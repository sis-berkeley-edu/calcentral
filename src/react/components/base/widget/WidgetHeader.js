import React from 'react';
import PropTypes from 'prop-types';

class WidgetHeader extends React.Component {
  render() {
    return (
      <div className="cc-widget-title">
        <h2>{this.props.title}</h2>
      </div>
    );
  }
}
WidgetHeader.propTypes = {
  title: PropTypes.string.isRequired
};

export default WidgetHeader;

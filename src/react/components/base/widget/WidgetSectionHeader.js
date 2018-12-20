import React from 'react';
import PropTypes from 'prop-types';

import '../../../stylesheets/widgets.scss';

class WidgetSectionHeader extends React.Component {
  render() {
    return (
      <div className="cc-react-widget-section-title">
        <h2>{this.props.title}</h2>
      </div>
    );
  }
}
WidgetSectionHeader.propTypes = {
  title: PropTypes.string.isRequired
};

export default WidgetSectionHeader;

import React from 'react';
import PropTypes from 'prop-types';

import WidgetHeader from './WidgetHeader';
import '../../../stylesheets/widgets.scss';

const Widget = (props) => {
  return (
    // class "cc-widget" is necessary for now for 2-column and 3-column margins. See _widgets.scss
    <div className="cc-react-widget cc-widget">
      <WidgetHeader title={props.config.title} />
      {props.renderWidgetBody()}
    </div>
  );
}
Widget.propTypes = {
  children: PropTypes.node.isRequired,
  config: PropTypes.object.isRequired,
  renderWidgetBody: PropTypes.func.isRequired
};

export default Widget;

import React from 'react';
import PropTypes from 'prop-types';

import WidgetBody from './WidgetBody';
import WidgetHeader from './WidgetHeader';

import '../../stylesheets/box_model.scss';
import '../../stylesheets/print.scss';
import '../../stylesheets/widgets.scss';

const defaultProps = {
  config: {
    errored: false,
    errorMessage: 'Card is unavailable at this time.',
    isLoading: false,
    padding: true,
    visible: true
  }
};

const propTypes = {
  children: PropTypes.node.isRequired,
  config: PropTypes.shape({
    errored: PropTypes.bool,
    errorMessage: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.node
    ]),
    isLoading: PropTypes.bool,
    padding: PropTypes.bool,
    title: PropTypes.string.isRequired,
    visible: PropTypes.bool
  })
};

const Widget = (props) => {
  const {config: widgetConfig, children} = props;
  if (widgetConfig.visible) {
    return (
      // class "cc-widget" is necessary for now for 2-column and 3-column margins. See _widgets.scss
      <div className="cc-react-widget cc-widget">
        <WidgetHeader title={widgetConfig.title} />
        <WidgetBody widgetConfig={widgetConfig}>
          {children}
        </WidgetBody>
      </div>
    );
  } else {
    return null;
  }
};

Widget.defaultProps = defaultProps;
Widget.propTypes = propTypes;

export default Widget;

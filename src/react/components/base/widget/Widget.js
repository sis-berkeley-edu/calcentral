import React from 'react';
import PropTypes from 'prop-types';

import Spinner from '../Spinner';
import WidgetBody from './WidgetBody';
import WidgetHeader from './WidgetHeader';

import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/print.scss';
import '../../../stylesheets/widgets.scss';

const renderErrorMessage = (errorMessage) => {
  let messageComponent;
  if (typeof errorMessage === 'string' || errorMessage instanceof String) {
    messageComponent = (<p className="cc-react-no-margin">{errorMessage}</p>);
  } else {
    messageComponent = errorMessage;
  }
  return (
    <div className="cc-react-widget-padding">
      {messageComponent}
    </div>
  );
};

const renderWidgetBody = (widgetConfig, children) => {
  if (widgetConfig.errored) {
    return renderErrorMessage(widgetConfig.errorMessage);
  } else if (widgetConfig.isLoading) {
    return <Spinner isLoadingMessage={widgetConfig.isLoadingMessage} />;
  } else {
    return (
      <WidgetBody padding={widgetConfig.padding}>
        {children}
      </WidgetBody>
    );
  }
};

const renderWidget = (widgetConfig, children) => {
  if (widgetConfig.visible) {
    return (
      // class "cc-widget" is necessary for now for 2-column and 3-column margins. See _widgets.scss
      <div className="cc-react-widget cc-widget">
        <WidgetHeader title={widgetConfig.title} />
        {renderWidgetBody(widgetConfig, children)}
      </div>
    );
  } else {
    return null;
  }
};

const Widget = (props) => {
  return renderWidget(props.config, props.children);
};

Widget.defaultProps = {
  config: {
    errored: false,
    errorMessage: 'Card is unavailable at this time.',
    isLoading: false,
    padding: true,
    visible: true
  }
};
Widget.propTypes = {
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

export default Widget;

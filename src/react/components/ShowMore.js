import React from 'react';
import PropTypes from 'prop-types';

import Icon from './Icon/Icon';
import { ICON_CHEVRON_DOWN, ICON_CHEVRON_UP } from './Icon/IconTypes';

import '../stylesheets/buttons.scss';
import '../stylesheets/widgets.scss';

const propTypes = {
  clickHandler: PropTypes.func.isRequired,
  expanded: PropTypes.bool.isRequired,
  text: PropTypes.string.isRequired,
  view: PropTypes.node.isRequired
};

const renderButtonText = (expanded, text) => {
  if (expanded) {
    return (
      <React.Fragment>
        Show Less <Icon name={ICON_CHEVRON_UP} />
      </React.Fragment>
    );
  } else {
    return (
      <React.Fragment>
        {text} <Icon name={ICON_CHEVRON_DOWN} />
      </React.Fragment>
    );
  }
};

const renderExpanded = (expanded, view) => {
  if (expanded) {
    return view;
  }
};

const ShowMore = (props) => {
  return (
    <React.Fragment>
      <div className="cc-react-widget--padding cc-react-text--align-center">
        <button onClick={props.clickHandler} className="cc-react-button--link">{renderButtonText(props.expanded, props.text)}</button>
      </div>
      { renderExpanded(props.expanded, props.view) }
    </React.Fragment>
  );
};
ShowMore.propTypes = propTypes;

export default ShowMore;

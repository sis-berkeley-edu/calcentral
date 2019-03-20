import React, { Component } from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = {
  children: PropTypes.node,
  title: PropTypes.string,
  state: PropTypes.string,
  actionLink: PropTypes.object,
  serviceIndicator: PropTypes.object
};

class HoldListItem extends Component {
  constructor(props) {
    super(props);
    this.state = { expanded: false };
  }

  toggle() {
    if (this.props.children) {
      this.setState({ expanded: !this.state.expanded });
    }
  }

  classNames() {
    if (this.state.expanded) {
      return 'cc-widget-list-hover cc-widget-list-hover-opened';
    } else if (this.props.children) {
      return 'cc-widget-list-hover';
    } else {
      return 'cc-widget-list-hover cc-widget-list-hover-notriangle';
    }
  }

  render() {
    return (
      <li className={this.classNames()} tabIndex="0" onClick={() => this.toggle()}>
        <div className="cc-status-holds-list-section">
          <div className="cc-status-holds-list-item">
            <span>
              {this.props.state === 'green' &&
                <i className="cc-icon fa fa-check-circle cc-icon-green"></i>
              }

              {this.props.state === 'red' &&
                <i className="cc-icon fa fa-exclamation-circle cc-icon-red"></i>
              }
            </span>
            <span style={{ marginLeft: '3px' }}>
              {this.props.title}&nbsp;
              {this.props.actionLink &&
                <APILink {...this.props.actionLink} name="Take action" />
              }
            </span>
          </div>
          {this.state.expanded &&
            <div className="cc-status-holds-expanded-text">
              {this.props.children}
            </div>
          }
        </div>
      </li>
    );
  }
}

HoldListItem.propTypes = propTypes;

export default HoldListItem;

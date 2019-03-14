import React, { Component } from 'react';
import PropTypes from 'prop-types';
import './InstructingAppointments.scss';

const propTypes = {
  classes: PropTypes.array.isRequired,
  hasCurrentClasses: PropTypes.bool.isRequired,
  hasPreviousClasses: PropTypes.bool.isRequired
};

class InstructingAppointments extends Component {
  constructor(props) {
    super(props);
    this.state = { showPreviousClasses: false };
  }

  revealPreviousClasses() {
    this.setState({ showPreviousClasses: !this.state.showPreviousClasses});
  }

  render() {
    return (
      <div className="InstructingAppointments">
        <div className="InstructingAppointments__header">
          <h3>Instructing</h3>

          { this.props.hasPreviousClasses && !this.state.showPreviousClasses &&
            <button className="cc-button-link" onClick={() => this.revealPreviousClasses() }>
              View previous classes
            </button>
          }
        </div>

        { !this.props.hasCurrentClasses && <p>Not currently teaching any classes.</p> }

        { this.props.classes.map(klass => {
          if (klass.timeBucket !== 'past' || this.state.showPreviousClasses) {
            return (
              <div className="InstructingClassRow" key={`${klass.name}-${klass.semesterName}`}>
                <div className="InstructingClassRow__title">{klass.title}</div>
                <div className="InstructingClassRow__semester">{klass.semesterName}</div>
              </div>
            );
          }
        })}
      </div>
    );
  }
}

InstructingAppointments.propTypes = propTypes;

export default InstructingAppointments;

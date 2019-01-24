import React, { Component, Fragment } from 'react';

class HubTermLegacyNote extends Component {
  constructor(props) {
    super(props);
    this.state = { showMore: false };
  }

  toggle() {
    this.setState({ showMore: !this.state.showMore });
  }

  render() {
    return (
      <span className="cc-academic-summary-legacy-note">
        <strong>Note: </strong>
        Enrollment data for current term and back to Spring 2010 (where applicable) is displayed.&nbsp;

        {this.state.showMore
          ? (
            <Fragment>
              If enrollments exist in terms prior to Spring 2010, the
              data will be displayed in Summer 2017. If you require a full record
              now, please order a transcript.
            </Fragment>
          )
          : <button className="cc-button-link" onClick={() => this.toggle()}>Show more</button>
        }
      </span>
    );
  }
}

export default HubTermLegacyNote;

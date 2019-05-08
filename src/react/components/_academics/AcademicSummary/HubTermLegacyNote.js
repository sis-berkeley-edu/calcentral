import React, { Fragment, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  hubTermApiEnabled: PropTypes.bool
};

const HubTermLegacyNote = ({ hubTermApiEnabled }) => {
  const [showMore, setShowMore] = useState(false);

  if (hubTermApiEnabled) {
    return (
      <span className="cc-academic-summary-legacy-note">
        <strong>Note: </strong>
        Enrollment data for current term and back to Spring 2010 (where applicable) is displayed.&nbsp;

        {showMore
          ? (
            <Fragment>
              If enrollments exist in terms prior to Spring 2010, the
              data will be displayed in Summer 2017. If you require a full record
              now, please order a transcript.
            </Fragment>
          )
          : <button className="cc-button-link" onClick={() => setShowMore(!showMore)}>Show more</button>
        }
      </span>
    );
  } else {
    return null;
  }
};

HubTermLegacyNote.propTypes = propTypes;

const mapStateToProps = ({ myStatus }) => {
  const {
    features: {
      hubTermApi: hubTermApiEnabled
    } = {}
  } = myStatus;

  return {
    hubTermApiEnabled
  };
};

export default connect(mapStateToProps)(HubTermLegacyNote);

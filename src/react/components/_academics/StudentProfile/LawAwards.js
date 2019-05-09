import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const formatNote = note => `${note.note} ${note.termName}: ${note.classDescription}`;
const formatAward = award => award.description;

const propTypes = {
  awards: PropTypes.array,
  transcriptNotes: PropTypes.array,
  showLink: PropTypes.bool
};

const defaultProps = {
  awards: [],
  transcriptNotes: [],
  showLink: false
};

const AwardsLink = ({ awardCount }) => {
  const summaryPath = '/academics/academic_summary';

  if (awardCount === 1) {
    return <a href={summaryPath}>Academic Award</a>;
  } else {
    return <a href={summaryPath}>Academic Awards</a>;
  }
};

const LawAwards = ({ awards, transcriptNotes, showLink }) => {
  const awardsAndNotes = [...awards, ...transcriptNotes];
  const awardCount = awardsAndNotes.length;

  if (awardCount) {
    return (
      <tr>
        <th>
          Academic Awards
        </th>
        <td>
          { showLink
            ? <AwardsLink awardCount={awardCount} />
            : (
              <Fragment>
                {awards.map((award, index) => <div key={index}>{formatAward(award)}</div>) }
                {transcriptNotes.map((note, index) => <div key={index}>{formatNote(note)}</div>) }
              </Fragment>
            )
          }
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

LawAwards.propTypes = propTypes;
LawAwards.defaultProps = defaultProps;

const mapStateToProps = ({
  myLawAwards: { awards, transcriptNotes } = {}
}) => {
  return { awards, transcriptNotes };
};

export default connect(mapStateToProps)(LawAwards);

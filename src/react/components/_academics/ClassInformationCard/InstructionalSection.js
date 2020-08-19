import React from 'react';
import PropTypes from 'prop-types';

import 'icons/calendar.svg';
import 'icons/pin.svg';
import 'icons/tag.svg';
import 'icons/clock.svg';
import styles from './InstructionalSection.module.scss';

import RecurringSession from './RecurringSession';
import IndividualSession from './IndividualSession';

export default function InstructionalSection({ section }) {
  const {
    section_label: label,
    ccn: courseCatalogNumber,
    schedules,
    instructionMode,
    timeConflictOverride,
    async,
    cloud,
  } = section;

  const {
    recurring: recurringSessions = [],
    oneTime: individualSessions = [],
  } = schedules;

  const meetingDetails = [async, cloud, timeConflictOverride].filter(
    item => item
  );

  return (
    <div className={styles.instructionalSection}>
      <div>
        <h2 className={styles.title}>
          {label}
          <span className={styles.catalogNumber}>
            {' '}
            • Class # {courseCatalogNumber}
          </span>
        </h2>
      </div>
      <table className={`table ${styles.sectionDetails}`}>
        <tbody>
          <tr>
            <th className={styles.instructionMode}>Instruction Mode</th>
            <td>{instructionMode}</td>
          </tr>
          {meetingDetails.length > 0 && (
            <tr>
              <th className={styles.meetingDetails}>Meeting Details</th>
              <td>{meetingDetails.join(' • ')}</td>
            </tr>
          )}
          {recurringSessions.length > 0 && (
            <tr>
              <th className={styles.schedule}>Schedule</th>
              <td>
                {recurringSessions.map(session => (
                  <RecurringSession key={session.schedule} session={session} />
                ))}
              </td>
            </tr>
          )}
          {individualSessions.length > 0 && (
            <tr>
              <th className={styles.individualSessions}>Individual Sess.</th>
              <td>
                {individualSessions.map(session => (
                  <IndividualSession key={session.date} session={session} />
                ))}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

InstructionalSection.propTypes = {
  section: PropTypes.object,
  isInstructor: PropTypes.bool,
};

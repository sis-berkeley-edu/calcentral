import React from 'react';
import PropTypes from 'prop-types';

import { format, parseISO } from 'date-fns';

const LawTimeCell = ({ time }) => {
  if (time) {
    const formattedDate = format(time, 'MMM d');
    const formattedTime = format(time, 'h:mma');

    return (
      <>
        <strong>{formattedDate} | </strong>
        <span style={{ fontWeight: `normal` }}>
          {formattedTime.toLowerCase()}
        </span>
      </>
    );
  }

  return null;
};

LawTimeCell.propTypes = {
  time: PropTypes.instanceOf(Date),
};

const LawEnrollmentAppointments = ({
  appointmentTerm: {
    enrollmentPeriods,
    constraints: { maxUnits, deadlines = [] } = {},
  } = {},
  termIsSummer,
}) => {
  if (termIsSummer) {
    const period = enrollmentPeriods[0];
    const time = parseISO(period.date.datetime);

    return (
      <div style={{ marginBottom: `15px`, marginTop: `15px` }}>
        <h4 className="cc-enrollment-card-headersub-title">
          Law Enrollment Period <span>(Pacific Time Zone)</span>
        </h4>

        <div className="cc-table" style={{ marginTop: `10px` }}>
          <table>
            <tbody>
              <tr>
                <td>
                  <span className="cc-text-light">
                    <strong>Begin Enrollment</strong>
                  </span>
                </td>
                <td>{maxUnits} Units Max</td>
                <td>
                  <strong>{format(time, 'E')}</strong>
                </td>
                <td>
                  <LawTimeCell time={time} />
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <h4 className="cc-enrollment-card-headersub-title">
          Law Add/Drop Deadlines
        </h4>

        <div className="cc-table" style={{ marginTop: `10px` }}>
          <table>
            <tbody>
              {deadlines.map(deadline => {
                const time = parseISO(deadline.addDeadlineDatetime);

                return (
                  <tr key={deadline.session}>
                    <td>
                      <span className="cc-text-light">
                        <strong>
                          {deadline.session.replace('Summer LLM', '')}
                        </strong>
                      </span>
                    </td>
                    <td>
                      <strong>{format(time, 'E')}</strong>
                    </td>
                    <td>
                      <LawTimeCell time={time} />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="cc-enrollment-card-margin-bottom">
        Below are your enrollment appointment start and end times. You will have
        continuous access to the system until the semester&apos;s add/drop
        deadline:
      </div>
      <div style={{ marginBottom: `15px`, marginTop: `15px` }}>
        <h4 className="cc-enrollment-card-headersub-title">
          Law Enrollment Period <span>(Pacific Time Zone)</span>
        </h4>

        <div className="cc-table" style={{ marginTop: `10px` }}>
          <table>
            <tbody>
              {enrollmentPeriods.map(period => {
                const time = parseISO(period.date.datetime);

                return (
                  <tr key={period.id}>
                    <td>
                      <span className="cc-text-light">
                        <strong>{period.name.replace(' Begins', '')}</strong>
                      </span>
                    </td>
                    <td>
                      <strong>{format(time, 'E')}</strong>
                    </td>
                    <td>
                      <LawTimeCell time={time} />
                    </td>
                  </tr>
                );
              })}

              {deadlines.map(deadline => {
                const time = parseISO(deadline.addDeadlineDatetime);

                return (
                  <tr key={deadline.session}>
                    <td>
                      <span className="cc-text-light">
                        <strong>Law Add/Drop Deadline</strong>
                      </span>
                    </td>
                    <td>
                      <strong>{format(time, 'E')}</strong>
                    </td>
                    <td>
                      <LawTimeCell time={time} />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
};

LawEnrollmentAppointments.propTypes = {
  appointmentTerm: PropTypes.object,
  termIsSummer: PropTypes.bool,
};

export default LawEnrollmentAppointments;

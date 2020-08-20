import React from 'react';
import PropTypes from 'prop-types';

import styles from './FinalExams.module.scss';

const examDescription = ({ exam_date, exam_time, exam_location }) =>
  [exam_date, exam_time, exam_location].filter(item => item).join(' • ');

// Get finals from a list of sections, ignoring those without an exam_date or
// exam_time (those have a message indicating that "Exam Information not
// available at this time."
const extractFinals = (acc, section) => {
  const { finalExams } = section;

  if (finalExams) {
    const exams = finalExams.filter(exam => exam.exam_date || exam.exam_time);
    return [
      ...acc,
      ...exams.map(exam => ({
        ...exam,
        sectionLabel: section.section_label,
        key: `${section.section_label}-${exam.exam_date}-${exam.exam_time}`,
      })),
    ];
  }

  return acc;
};

const FinalsTable = ({ exams }) => {
  return (
    <table className={`table ${styles.finalsTable}`}>
      <tbody>
        {exams.map(exam => (
          <tr key={exam.key}>
            <th>{exam.sectionLabel}</th>
            <td>{examDescription(exam)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

FinalsTable.propTypes = {
  exams: PropTypes.arrayOf(
    PropTypes.shape({
      sectionLabel: PropTypes.string,
      exam_date: PropTypes.string,
      exam_time: PropTypes.string,
      exam_location: PropTypes.string,
    })
  ),
};

export default function FinalExams({ sections }) {
  const exams = sections.reduce(extractFinals, []);

  if (exams.length === 0) {
    return null;
  }

  return (
    <div className={styles.finalExams}>
      <h2 className={styles.title}>Final Exam Schedule</h2>
      {exams.length === 1 ? (
        <div>{examDescription(exams[0])}</div>
      ) : (
        <FinalsTable exams={exams} />
      )}
    </div>
  );
}

FinalExams.propTypes = {
  sections: PropTypes.array,
};

import React from 'react';
import PropTypes from 'prop-types';

import Card from 'react/components/Card';

import ClassAttributesTable from './ClassAttributesTable';
import InstructionalSection from './InstructionalSection';
import VerticalSpacer from 'react/components/VerticalSpacer';
import ClassInfoNotice from '../ClassInfoNotice';
import FinalExams from './FinalExams';

import styles from './ClassInformationCard.module.scss';
import CrossListings from './CrossListings';

export default function ClassInformationCard({
  loaded,
  termId,
  isInstructor,
  course: {
    title,
    units,
    isLaw,
    role,
    gradingBasis,
    classNotesLink,
    sections,
    semesterSlug,
    slug,
    listings,
  },
}) {
  return (
    <Card
      title="Class Information Card"
      loading={!loaded}
      style={{ marginRight: `15px` }}
    >
      <VerticalSpacer />
      <ClassInfoNotice termId={termId} />

      <h1 className={styles.title}>{title}</h1>

      <ClassAttributesTable
        role={role}
        units={units}
        gradingBasis={gradingBasis}
        classNotesLink={classNotesLink}
        isLaw={isLaw}
        semesterSlug={semesterSlug}
        slug={slug}
        isInstructor={isInstructor}
        primarySection={sections.find(section => section.is_primary_section)}
      />

      <hr />

      <CrossListings listings={listings} />

      {sections.map(section => (
        <InstructionalSection
          key={section.section_label}
          section={section}
          isInstructor={isInstructor}
        />
      ))}

      <FinalExams sections={sections} />
    </Card>
  );
}

ClassInformationCard.displayName = 'ClassInformationCard';

ClassInformationCard.propTypes = {
  loaded: PropTypes.bool,
  isInstructor: PropTypes.bool,
  termId: PropTypes.string,
  course: PropTypes.shape({
    title: PropTypes.string,
    isLaw: PropTypes.bool,
    units: PropTypes.number,
    sections: PropTypes.array,
    role: PropTypes.string,
    gradingBasis: PropTypes.string,
    classNotesLink: PropTypes.string,
    semesterSlug: PropTypes.string,
    slug: PropTypes.string,
    listings: PropTypes.array,
  }),
};

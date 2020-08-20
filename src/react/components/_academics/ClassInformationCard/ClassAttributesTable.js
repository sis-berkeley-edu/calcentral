import React from 'react';
import PropTypes from 'prop-types';

import isPresent from 'functions/isPresent';

import HorizontalClassAttributes from './HorizontalClassAttributes';
import VerticalClassAttributes from './VerticalClassAttributes';

const propTypes = {
  role: PropTypes.string,
  units: PropTypes.number,
  gradingBasis: PropTypes.string,
  isLaw: PropTypes.bool,
  semesterSlug: PropTypes.string,
  slug: PropTypes.string,
  sections: PropTypes.array,
  isInstructor: PropTypes.bool,
};

function classNotesLink(semesterSlug, slug, primarySection) {
  const [season, year] = semesterSlug.split('-');

  return `https://classes.berkeley.edu/content/${year}-${season}-${slug}-${
    primarySection.section_number
  }-${primarySection.section_label.toLowerCase().replace(' ', '-')}`;
}

function tableOrientation({ role, isInstructor, isLaw, units, gradingBasis }) {
  const showClassNotesLink = !isLaw;

  // The number of items to show in the table.
  //
  // If the user is an instructor don't show units or grading basis.
  // Filter any attributes that are null.
  const countToShow = [
    role,
    isInstructor ? null : units,
    isInstructor ? null : gradingBasis,
    showClassNotesLink,
  ].filter(isPresent).length;

  if (countToShow > 2) {
    return 'horizontal';
  }

  return 'vertical';
}

export default function ClassAttributesTable({
  role,
  units,
  semesterSlug,
  slug,
  sections,
  isInstructor,
  isLaw,
}) {
  const primarySection = sections.find(section => section.is_primary_section);
  const { grading: { gradingBasis } = {} } = primarySection;
  const academicGuide = classNotesLink(semesterSlug, slug, primarySection);

  const orientation = tableOrientation({
    role,
    isInstructor,
    isLaw,
    gradingBasis,
    units,
  });

  if (orientation === 'horizontal') {
    return (
      <HorizontalClassAttributes
        role={role}
        units={units}
        gradingBasis={gradingBasis}
        semesterSlug={semesterSlug}
        academicGuide={academicGuide}
        isLaw={isLaw}
      />
    );
  }

  return (
    <VerticalClassAttributes
      role={role}
      units={units}
      gradingBasis={gradingBasis}
      semesterSlug={semesterSlug}
      academicGuide={academicGuide}
      isLaw={isLaw}
    />
  );
}

ClassAttributesTable.propTypes = propTypes;

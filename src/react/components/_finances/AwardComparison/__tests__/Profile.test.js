import {
  differencesBetween,
  countDifferencesBetween,
} from '../AwardComparison.module';

const oneFamilyMember = {
  description: 'Family Members in College',
  value: '1',
};

const twoFamilyMembers = {
  description: 'Family Members in College',
  value: '2',
};

const sapStatusMeetingRequirements = {
  description: 'SAP Status',
  value: 'Meeting Requirements',
};

const sapStatusNull = {
  description: 'SAP Status',
  value: null,
};

describe('Comparer function', () => {
  test('returns the count of differences in the arrays', () => {
    const snapshot = [oneFamilyMember, sapStatusMeetingRequirements];
    const current = [twoFamilyMembers, sapStatusNull];

    expect(differencesBetween(snapshot)(current)).toBe(2);
  });
});

describe('differencesBetween', () => {
  describe('With a single value item', () => {
    test('when snapshot have different values', () => {
      const snapshot = oneFamilyMember;
      const current = twoFamilyMembers;

      expect(countDifferencesBetween(snapshot, current)).toBe(1);
    });

    test('when snapshot have the same values', () => {
      const snapshot = oneFamilyMember;
      const current = oneFamilyMember;

      expect(countDifferencesBetween(snapshot, current)).toBe(0);
    });
  });

  describe('With multiple terms per item', () => {
    const fallFouthYear = {
      term: 'Fall',
      value: '4th Year',
    };

    test('When a term is present in both and values the same', () => {
      const snapshot = {
        description: 'Level',
        subvalues: [fallFouthYear],
      };

      const current = {
        description: 'Level',
        subvalues: [fallFouthYear],
      };

      expect(countDifferencesBetween(snapshot, current)).toBe(0);
    });

    test('When a term is present only in the current', () => {
      const snapshot = {
        description: 'Level',
        subvalues: [],
      };

      const current = {
        description: 'Level',
        subvalues: [fallFouthYear],
      };

      expect(countDifferencesBetween(snapshot, current)).toBe(1);
    });

    test('When a term is present only in the snapshot', () => {
      const snapshot = {
        description: 'Level',
        subvalues: [fallFouthYear],
      };

      const current = {
        description: 'Level',
        subvalues: [],
      };

      expect(countDifferencesBetween(snapshot, current)).toBe(1);
    });

    test('When a term is present in both but values different', () => {
      const snapshot = {
        description: 'Level',
        subvalues: [fallFouthYear],
      };

      const current = {
        description: 'Level',
        subvalues: [{ term: 'Fall', value: '3rd Year' }],
      };

      expect(countDifferencesBetween(snapshot, current)).toBe(1);
    });
  });
});

test('enrollment changes', () => {
  const current = [
    {
      description: 'Enrollment',
      subvalues: [
        { term: 'Fall', value: '13 Units' },
        { term: 'Spring', value: '9 Units' },
        { term: 'Summer', value: '6 Units' },
      ],
    },
  ];

  const snapshot = [
    {
      description: 'Enrollment',
      subvalues: [{ term: 'Fall', value: '6 Units' }],
    },
  ];

  expect(differencesBetween(snapshot)(current)).toBe(3);
});

test('real world data', () => {
  const current = [
    {
      description: 'Level',
      subvalues: [
        { term: 'Fall', value: '4th Year' },
        { term: 'Spring', value: '4th Year' },
        { term: 'Summer', value: '4th Year' },
      ],
    },
    {
      description: 'Enrollment',
      subvalues: [
        { term: 'Fall', value: '6 Units' },
        { term: 'Spring', value: '9 Units' },
        { term: 'Summer', value: '6 Units' },
      ],
    },
    {
      description: 'Residency',
      subvalues: [
        { term: 'Fall', value: 'Resident' },
        { term: 'Spring', value: 'Resident' },
        { term: 'Summer', value: 'Resident' },
      ],
    },
    {
      description: 'Housing',
      subvalues: [
        { term: 'Fall', value: 'Family Housing' },
        { term: 'Spring', value: 'Family Housing' },
      ],
    },
    {
      description: 'SHIP (Student Housing Insurance Program)',
      subvalues: [
        { term: 'Fall', value: 'Enrolled' },
        { term: 'Spring', value: 'Enrolled' },
        { term: 'Summer', value: 'Not Enrolled' },
      ],
    },
    { description: 'SAP Status', value: 'Meeting Requirements' },
    { description: 'Verification Status', value: 'Verified' },
    { description: 'Family Members in College', value: '1' },
    { description: 'Estimated Graduation', value: 'Fall 2020' },
    { description: 'Dependency Status', value: 'Independent' },
    { description: 'Expected Family Contribution (EFC)', value: 0 },
    { description: 'Berkeley Parent Contribution', value: 0 },
  ];

  const snapshot = [
    {
      description: 'Level',
      subvalues: [
        { term: 'Fall', value: '4th Year' },
        { term: 'Spring', value: '4th Year' },
      ],
    },
    {
      description: 'Enrollment',
      subvalues: [{ term: 'Fall', value: '13 Units' }],
    },
    {
      description: 'Residency',
      subvalues: [
        { term: 'Fall', value: 'Resident' },
        { term: 'Spring', value: 'Resident' },
      ],
    },
    {
      description: 'Housing',
      subvalues: [
        { term: 'Fall', value: 'Family Housing' },
        { term: 'Spring', value: 'Family Housing' },
      ],
    },
    {
      description: 'SHIP (Student Housing Insurance Program)',
      subvalues: [
        { term: 'Fall', value: 'Enrolled' },
        { term: 'Spring', value: 'Enrolled' },
      ],
    },
    { description: 'SAP Status', value: null },
    { description: 'Verification Status', value: null },
    { description: 'Family Members in College', value: '1' },
    { description: 'Estimated Graduation', value: 'Fall 2020' },
    { description: 'Dependency Status', value: 'Independent' },
    { description: 'Expected Family Contribution (EFC)', value: 0 },
    { description: 'Berkeley Parent Contribution', value: 0 },
  ];

  expect(differencesBetween(snapshot)(current)).toBe(8);
});

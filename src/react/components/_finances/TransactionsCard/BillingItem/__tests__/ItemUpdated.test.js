import React from 'react';
import { render } from '@testing-library/react';

import ItemUpdated from '../ItemUpdated';
import { subDays, formatISO } from 'date-fns';

const daysAgoDateString = count => formatISO(subDays(new Date(), count));

test('renders null if posted_on and updated_on are the same', () => {
  const item = {
    posted_on: daysAgoDateString(0),
    updated_on: daysAgoDateString(0),
  };

  const { container } = render(<ItemUpdated item={item} />);
  expect(container.querySelector('div')).toBeNull();
});

test('renders "Updated today" if true', async () => {
  const item = {
    posted_on: daysAgoDateString(10),
    updated_on: daysAgoDateString(0),
  };

  const { getByText } = render(<ItemUpdated item={item} />);
  expect(getByText('Updated today')).toBeTruthy();
});

test('renders "Updated X days ago" if updated less than 30 days ago', () => {
  const item = {
    posted_on: daysAgoDateString(10),
    updated_on: daysAgoDateString(5),
  };

  const { getByText } = render(<ItemUpdated item={item} />);
  expect(getByText('Updated 5 days ago')).toBeTruthy();
});

test('renders null if updated more than 30 days ago', () => {
  const item = {
    posted_on: daysAgoDateString(0),
    updated_on: daysAgoDateString(31),
  };

  const { container } = render(<ItemUpdated item={item} />);
  expect(container.querySelector('div')).toBeNull();
});

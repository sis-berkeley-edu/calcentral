import React from 'react';
import { render } from '@testing-library/react';

import CompletedTask from '../CompletedTask';

describe('Waived items', () => {
  test('correctly show the waived date', () => {
    const task = {
      dueDate: '2019-07-15',
      completedDate: '2020-02-24',
      status: 'Waived',
      title: 'College E-Transcript',
    };

    const { getByText } = render(<CompletedTask task={task} />);
    expect(getByText('Waived Feb 24'));
  });
});

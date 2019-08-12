import { CHARGE_DUE, CHARGE_OVERDUE, CHARGE_NOT_DUE } from '../chargeStatuses';

const statusClassName = (status) => {
  switch (status) {
    case CHARGE_OVERDUE:
      return 'Badge--overdue';
    case CHARGE_DUE:
      return 'Badge--due';
    case CHARGE_NOT_DUE:
      return 'Badge--not-due';
    default:
      return null;
  }
};

export default statusClassName;

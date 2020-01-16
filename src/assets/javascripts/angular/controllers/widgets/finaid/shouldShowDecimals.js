const notInteger = value => !Number.isInteger(value);

const termHasDecimal = term => {
  return notInteger(term.offered) || notInteger(term.disbursed);
};

const itemHasDecimal = item => {
  const {
    leftColumn: { amount: leftAmount } = {},
    rightColumn: { amount: rightAmount } = {},
    subItems: { remainingAmount, termDetails = [] } = {},
  } = item;

  return [leftAmount, rightAmount, remainingAmount]
    .filter(Boolean)
    .find(notInteger)
    ? true
    : !!termDetails.filter(Boolean).find(termHasDecimal);
};

const totalAwardHasDecimal = award => {
  const { total: { amount } = {}, items } = award;

  return notInteger(amount)
    ? true
    : !!items.filter(Boolean).find(itemHasDecimal);
};

const shouldShowDecimals = ({
  awards: {
    giftaid,
    waiversAndOther,
    workstudy,
    subsidizedloans,
    unsubsidizedloans,
    plusloans,
    alternativeloans,
  },
}) => {
  const awardTypes = [
    giftaid,
    waiversAndOther,
    workstudy,
    subsidizedloans,
    unsubsidizedloans,
    plusloans,
    alternativeloans,
  ];

  // .filter(Boolean) will remove any null awardTypes
  return !!awardTypes.filter(Boolean).find(totalAwardHasDecimal);
};

export default shouldShowDecimals;

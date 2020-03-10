import { useState } from 'react';

function useShowMore(incrementBy) {
  const [shownCount, setShownCount] = useState(incrementBy);
  const showMore = () => {
    setShownCount(shownCount + incrementBy);
  };

  return [shownCount, showMore];
}

export default useShowMore;

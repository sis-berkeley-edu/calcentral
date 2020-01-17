import { useRef, useState, useEffect } from 'react';

function useFocus() {
  const node = useRef(null);
  const [hasFocus, setHasFocus] = useState(true);
  const outsideClick = e => setHasFocus(node.current.contains(e.target));

  useEffect(() => {
    document.addEventListener('mousedown', outsideClick);
    return () => removeEventListener('mousedown', outsideClick);
  }, []);

  return [node, hasFocus];
}

export default useFocus;

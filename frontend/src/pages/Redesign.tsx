import { usePageMetadata } from '../app/metadata/usePageMetadata';
import content from './redesign-content.html?raw';

export default function Redesign() {
  usePageMetadata({ title: 'Our Journey to a New Site' });
  return <div dangerouslySetInnerHTML={{ __html: content }} />;
}

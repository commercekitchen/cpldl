import type { User } from '../../auth/authState';

export function getSurveyPath(user: User | null): string {
  return user?.profileValid === false ? '/account' : '/survey';
}

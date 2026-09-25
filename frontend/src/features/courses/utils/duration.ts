import type { TFunction } from 'i18next';

export function formatDurationMinutes(durationSeconds: number, t: TFunction): string {
  return Number.isFinite(durationSeconds) && durationSeconds > 0
    ? t('courses.durationMins', { count: Math.floor(durationSeconds / 60) })
    : t('courses.durationTbd');
}

export function formatDurationLong(durationSeconds: number, t: TFunction): string {
  if (!Number.isFinite(durationSeconds) || durationSeconds <= 0) {
    return t('courses.durationTbd');
  }

  const totalMinutes = Math.floor(durationSeconds / 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (hours === 0) return t('courses.durationMins', { count: minutes });
  return t('courses.durationHoursMins', { hours, minutes });
}

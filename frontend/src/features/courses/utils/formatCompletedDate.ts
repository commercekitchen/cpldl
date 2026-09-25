export function formatCompletedDate(completedAt: string, locale: string): string {
  const date = new Date(completedAt);
  if (Number.isNaN(date.getTime())) return '';
  return new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'short', year: 'numeric' }).format(date);
}

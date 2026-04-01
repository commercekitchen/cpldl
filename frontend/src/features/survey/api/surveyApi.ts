import { apiFetch } from '../../../app/api/apiFetch';
import type { Survey, SurveyResponses } from '../types';

const ENDPOINT = '/api/v1/course_recommendation_survey';

type RawSurvey = {
  survey_required: boolean;
  questions: Array<{
    key: string;
    type: string;
    text: string;
    options: Array<{ value: string; label: string }>;
  }>;
};

export async function fetchSurvey(opts: { signal?: AbortSignal } = {}): Promise<Survey> {
  const res = await apiFetch(ENDPOINT, { signal: opts.signal });
  if (!res.ok) throw new Error(`Failed to load survey: ${res.status}`);
  const raw: RawSurvey = await res.json();
  return {
    surveyRequired: raw.survey_required,
    questions: raw.questions.map((q) => ({
      key: q.key,
      type: q.type as Survey['questions'][number]['type'],
      text: q.text,
      options: q.options,
    })),
  };
}

export async function submitSurvey(responses: SurveyResponses): Promise<void> {
  const res = await apiFetch(ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(responses),
  });
  if (!res.ok) throw new Error(`Failed to submit survey: ${res.status}`);
}

export async function dismissSurvey(): Promise<void> {
  const res = await apiFetch('/api/v1/profile/dismiss_survey', { method: 'POST' });
  if (!res.ok) throw new Error(`Failed to dismiss survey: ${res.status}`);
}

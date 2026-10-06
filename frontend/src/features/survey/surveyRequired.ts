import { redirect } from 'react-router-dom';

// Thrown by course/lesson fetchers when the org requires the recommendation
// survey and the signed-in user hasn't completed it yet.
export class SurveyRequiredError extends Error {
  constructor() {
    super('Survey required');
    this.name = 'SurveyRequiredError';
  }
}

export async function throwIfSurveyRequired(res: Response): Promise<void> {
  if (res.status !== 403) return;

  const body = (await res
    .clone()
    .json()
    .catch(() => null)) as { code?: string } | null;
  if (body?.code === 'survey_required') throw new SurveyRequiredError();
}

// Loader helper: turns a SurveyRequiredError into a redirect to the survey.
// The survey page itself sends users with incomplete profiles to /account.
export async function withSurveyRedirect<T>(load: () => Promise<T>): Promise<T> {
  try {
    return await load();
  } catch (err) {
    if (err instanceof SurveyRequiredError) throw redirect('/survey');
    throw err;
  }
}

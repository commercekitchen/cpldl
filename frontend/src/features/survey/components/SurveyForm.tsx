import { useState } from 'react';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import { useTranslation } from 'react-i18next';
import type { Survey, SurveyResponses } from '../types';
import { RadioQuestion } from './RadioQuestion';

type Props = {
  survey: Survey;
  onSubmit: (responses: SurveyResponses) => Promise<void>;
  onSkip?: () => void;
};

export function SurveyForm({ survey, onSubmit, onSkip }: Props) {
  const { t } = useTranslation();
  const [responses, setResponses] = useState<SurveyResponses>({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleChange = (key: string, value: string) => {
    setResponses((prev) => ({ ...prev, [key]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await onSubmit(responses);
    } catch {
      setError(t('survey.submitError'));
      setSubmitting(false);
    }
  };

  return (
    <Box component="form" onSubmit={(e) => { void handleSubmit(e); }}>
      {survey.questions.map((question, index) => {
        if (question.type === 'radio') {
          return (
            <RadioQuestion
              key={question.key}
              question={question}
              questionNumber={index + 1}
              value={responses[question.key] ?? ''}
              onChange={handleChange}
            />
          );
        }
        return null;
      })}

      {error && <Alert severity="error" role="alert" sx={{ mb: 2 }}>{error}</Alert>}

      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        <Button
          type="submit"
          variant="contained"
          disabled={submitting}
          startIcon={submitting ? <CircularProgress size={16} color="inherit" /> : undefined}
        >
          {submitting ? t('survey.submit') : t('survey.submit')}
        </Button>

        {!survey.surveyRequired && onSkip && (
          <Button variant="text" color="inherit" onClick={onSkip}>
            {t('survey.skip')}
          </Button>
        )}
      </Box>
    </Box>
  );
}

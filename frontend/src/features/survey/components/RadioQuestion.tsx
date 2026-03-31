import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormLabel from '@mui/material/FormLabel';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import type { SurveyQuestion } from '../types';

type Props = {
  question: SurveyQuestion;
  questionNumber: number;
  value: string;
  onChange: (key: string, value: string) => void;
};

export function RadioQuestion({ question, questionNumber, value, onChange }: Props) {
  return (
    <FormControl component="fieldset" sx={{ display: 'block', mb: 4 }}>
      <FormLabel component="legend" sx={{ mb: 1, fontWeight: 600, color: 'text.primary' }}>
        {questionNumber}. {question.text}
      </FormLabel>
      <RadioGroup
        value={value}
        onChange={(e) => onChange(question.key, e.target.value)}
      >
        {question.options.map((option) => (
          <FormControlLabel
            key={option.value}
            value={option.value}
            control={<Radio />}
            label={option.label}
          />
        ))}
      </RadioGroup>
    </FormControl>
  );
}

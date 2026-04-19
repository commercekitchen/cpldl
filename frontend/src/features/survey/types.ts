export type SurveyQuestionOption = {
  value: string;
  label: string;
};

// Only "radio" for now; new types can be added here as the survey evolves.
export type SurveyQuestionType = 'radio';

export type SurveyQuestion = {
  key: string;
  type: SurveyQuestionType;
  text: string;
  options: SurveyQuestionOption[];
};

export type Survey = {
  surveyRequired: boolean;
  questions: SurveyQuestion[];
};

// The shape sent back to the API — one string value per question key.
export type SurveyResponses = Record<string, string>;

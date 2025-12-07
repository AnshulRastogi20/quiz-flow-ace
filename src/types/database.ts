import { Json } from '@/integrations/supabase/types';

export interface DbQuiz {
  id: string;
  user_id: string;
  quiz_data: Json;
  created_at: string;
  updated_at: string;
}

export interface DbQuizParticipant {
  id: string;
  quiz_id: string;
  display_name: string;
  score: number | null;
  correct_count: number | null;
  joined_at: string;
}

export interface DbQuizAnswer {
  id: string;
  participant_id: string;
  quiz_id: string;
  question_id: string;
  selected_options: string[] | null;
  is_correct: boolean | null;
  points_earned: number | null;
  answered_at: string;
}

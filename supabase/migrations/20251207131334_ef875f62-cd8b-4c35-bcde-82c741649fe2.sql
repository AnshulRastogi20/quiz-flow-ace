-- Create quizzes table
CREATE TABLE public.quizzes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  quiz_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create quiz_participants table
CREATE TABLE public.quiz_participants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  score NUMERIC DEFAULT 0,
  correct_count INTEGER DEFAULT 0,
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create quiz_answers table
CREATE TABLE public.quiz_answers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  participant_id UUID NOT NULL REFERENCES public.quiz_participants(id) ON DELETE CASCADE,
  quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL,
  selected_options TEXT[] DEFAULT '{}',
  is_correct BOOLEAN DEFAULT false,
  points_earned NUMERIC DEFAULT 0,
  answered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_answers ENABLE ROW LEVEL SECURITY;

-- Quizzes policies (teachers only for their own quizzes)
CREATE POLICY "Users can create their own quizzes" ON public.quizzes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view their own quizzes" ON public.quizzes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own quizzes" ON public.quizzes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own quizzes" ON public.quizzes FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Anyone can view quizzes for joining" ON public.quizzes FOR SELECT USING (true);

-- Participants policies (public for guest join)
CREATE POLICY "Anyone can join as participant" ON public.quiz_participants FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can view participants" ON public.quiz_participants FOR SELECT USING (true);
CREATE POLICY "Anyone can update their own participation" ON public.quiz_participants FOR UPDATE USING (true);

-- Answers policies
CREATE POLICY "Anyone can submit answers" ON public.quiz_answers FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can view answers" ON public.quiz_answers FOR SELECT USING (true);

-- Enable realtime for participants
ALTER PUBLICATION supabase_realtime ADD TABLE public.quiz_participants;
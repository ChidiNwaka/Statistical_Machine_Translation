function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  
  logProb = 0;
    
  for i=1:length(words)-1
      
      curr_word = words{i};
      next_word = words{i+1};
      
      % Check if the next_word exist (bi-gram) in the LM and store it as
      % the numerator.
      if isfield(LM.bi, curr_word) && isfield(LM.bi.(curr_word), next_word)
          numerator = LM.bi.(curr_word).(next_word);
      else
          numerator = 0;
      end
      
      % Check if the curr_word exist in the LM, and store it as the
      % denominator
      if isfield(LM.uni, curr_word)
          denominator = LM.uni.(curr_word);
      else
          denominator = 0;
      end

      % Implement add-delta smoothing. There will be no change to the
      % values of numerator and denominator if there wasn't any values for
      % delta and vocabSize.
      numerator = numerator + delta;
      denominator = denominator + (delta * vocabSize);
      
      if (numerator == 0) && (denominator == 0)
          logProb = -Inf;
          return
      else
          logProb = logProb +log2(rdivide(numerator, denominator));
      end
  end
  
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
 return
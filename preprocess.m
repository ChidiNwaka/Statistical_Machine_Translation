function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

% global CSC401_A2_DEFNS 
  global CSC401_A2_DEFNS %= './helloWorld.e'
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;
%   disp(outSentence)
  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');

  % This adds a space in between words and punctuations.
  outSentence = regexprep( outSentence, '(\w*)([(\.)|(?)|(,)|(:)|(;)|(\()|(\))|((_))|(-)|(!)|(+)|(<)|(>)|(=)|(")])', '$1 $2');
  outSentence = regexprep( outSentence, '([(\.)|(?)|(,)|(:)|(;)|(\()|(\))|((_))|(-)|(!)|(+)|(<)|(>)|(=)|(")])(\w*)', '$1 $2');

  switch language
   case 'e'
    % TODO: your code here
    outSentence = regexprep(outSentence, '((?:(?!n''t).)*|(\w+))(n''t)', '$1 $2'); % adds space before n't
    outSentence = regexprep(outSentence, '(\w*)(''s)', '$1 $2'); % adds space between initial words and 's
    outSentence = regexprep(outSentence, '((?:(?!s'').)*|(\w+))('')', '$1 $2'); %adds space between initial word ending with s and '
    
    % Sample English sentence: haven't hasn't shouldn't chidi's dog's food. Thanks Douglas' bf.
    
   case 'f'
    % TODO: your code here 
    outSentence = regexprep(outSentence, '(l''|t''|j''|qu'')(\w*)', '$1 $2');
    
    % Sample French sentence: l'election je t'aime j'ai qu'on qu'll puissqu'on lorsqu'il biscif'el  
    
  end

  %Takes out extra spaces in between words.
  outSentence = regexprep( outSentence, '\s+', ' '); 
      
  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );


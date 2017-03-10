function LM = lm_train(dataDir, language, fn_LM)
%
%  lm_train
%
%  This function reads data from dataDir, computes unigram and bigram counts,
%  and writes the result to fn_LM
%
%  INPUTS:
%
%       dataDir     : (directory name) The top-level directory containing
%                                      data from which to train or decode
%                                      e.g., '/u/cs401/A2_SMT/data/Toy/'
%       language    : (string) either 'e' for English or 'f' for French
%       fn_LM       : (filename) the location to save the language model,
%                                once trained
%  OUTPUT:
%
%       LM          : (variable) a specialized language model structure
%
%  The file fn_LM must contain the data structure called 'LM',
%  which is a structure having two fields: 'uni' and 'bi', each of which holds
%  sub-structures which incorporate unigram or bigram COUNTS,
%
%       e.g., LM.uni.word = 5       % the word 'word' appears 5 times
%             LM.bi.word.bird = 2   % the bigram 'word bird' appears twice
%
% Template (c) 2011 Frank Rudzicz

global CSC401_A2_DEFNS

LM=struct();
LM.uni = struct();
LM.bi = struct();

SENTSTARTMARK = 'SENTSTART';
SENTENDMARK = 'SENTEND';

DD = dir( [ dataDir, filesep, '*', language] );

for iFile=1:length(DD)
    
    lines = textread([dataDir, filesep, DD(iFile).name], '%s','delimiter','\n');
    
    for l=1:length(lines)
        
        processedLine =  preprocess(lines{l}, language);
        words = strsplit(' ', processedLine );
        
        
        % TODO: THE STUDENT IMPLEMENTS THE FOLLOWING
        
        % Loop over each word in the sentence and compute it.
        for i=1:length(words)
            
            curr_word = words{i};
            
            if ~isempty(curr_word)

            
                % Handle unigram counts.
                if isfield(LM.uni, curr_word)
                    %If it currently exists in the unigram, increment it by 1.
                    LM.uni.(curr_word) = LM.uni.(curr_word) + 1;
                else
                    % Add it to the unigram and set its value to 1.
                    LM.uni.(curr_word) = 1;
                end

                % This handles bigram counts.
                if ~(i == 1) % do not include the first word in the sentence
                    % since there isn't any word preceeding it.

                    prev_word = words{i-1};

                    if isfield(LM.bi, prev_word) % Check if previous word exist in the bigram.
                        if isfield(LM.bi.(prev_word), curr_word)
                            % If there currently exist this particular bigram, increment by 1.
                            LM.bi.(prev_word).(curr_word) = LM.bi.(prev_word).(curr_word) + 1;
                        else    % add curr_word to form a new bigram.
                            LM.bi.(prev_word).(curr_word) = 1;
                        end
                    else
                        % If prev_word doesn't even exist, create it and add the
                        % new bigram.
                        LM.bi.(prev_word) = struct();
                        LM.bi.(prev_word).(curr_word) = 1;
                    end

                end
            end
            
        end
        
        % TODO: THE STUDENT IMPLEMENTED THE PRECEDING
    end
end

save( fn_LM, 'LM', '-mat');
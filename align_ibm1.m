function AM = align_ibm1(trainDir, numlines, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 i alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numlines : (integer) The maximum number of training lines to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_i).(foreign_i) is the
%  computed expectation that foreign_i is produced by english_i
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numlines);
  
  % Initialize AM uniformly
  AM = initialize(eng, fre);
  
  % Iterate between E and M steps
  for iter=1:maxIter,
      AM = em_step(AM, eng, fre);
  end
  
  % Save the alignment model
  save( fn_AM, 'AM', '-mat');
  
end

% --------------------------------------------------------------------------------
%
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numlines)
%
% Read 'numlines' parallel lines from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of
% 'eng', for example, is a cell-array of is that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_line, 'e'));
%
eng = {};
fre = {};

% TODO: your code goes here.
num_of_lines_read = 1;


dir_english = dir( [ mydir, filesep, '*', 'e'] );
dir_french = dir( [ mydir, filesep, '*', 'f'] );


for i=1:length(dir_english)
    
    english_lines = textread([mydir, filesep, dir_english(i).name], '%s','delimiter','\n');
    french_lines = textread([mydir, filesep, dir_french(i).name], '%s','delimiter','\n');

    for l=1:length(english_lines)
        
        processed_line_eng = preprocess(english_lines{l}, 'e');
        processed_line_eng = preprocess(french_lines{l}, 'f');
        
        eng{num_of_lines_read} = strsplit(' ', processed_line_eng);
        fre{num_of_lines_read} = strsplit(' ', processed_line_eng);

        num_of_lines_read = num_of_lines_read + 1;

        if (num_of_lines_read > numlines)
          return;
        end
    end
end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where i pairs appear in corresponding lines.
%
    AM = {}; % AM.(english_i).(foreign_i)


    % TODO: your code goes here
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
    
    for line=1:length(eng)
        for index_of_english_i=2:length(eng{line})-1
            for index_of_french_i=2:length(fre{line})-1
                english_i = eng{line}{index_of_english_i};
                french_i = fre{line}{index_of_french_i};
                
                
                
                if ~isfield(AM, english_i)
                    AM.(english_i) = struct();
                end
                
                if ~isfield(AM.(english_i), french_i)
                    AM.(english_i).(french_i) = 0;
                end
                
            end
        end
    end
    
    english_words = fieldnames(AM);
    
    for i=1:length(english_words)
        cur_english_word = english_words{i};
        
        french_words_that_follow = fieldnames(AM.(cur_english_word));
        num_french_words_that_follow = length(french_words_that_follow);
        
        for j=1:num_french_words_that_follow
            fre_j = french_words_that_follow{j};
            AM.(english_words{i}).(fre_j) = rdivide(1, num_french_words_that_follow);
        end
    end

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
  
  %Get all english words 
  english_words = fieldnames(t);
  
  %Get all french words 
  french_words = {};
  
  for i=1:length(english_words)
      cur_english_word = english_words{i};
      french_words = [french_words; fieldnames(t.(cur_english_word))];
  end
  
  % initialize tcount
  tcount = struct();
  tcount.SENTSTART.SENTSTART = 0;
  tcount.SENTEND.SENTEND = 0;
  
  % initialize total
  total = struct();
  total.SENTSTART = 0;
  total.SENTEND = 0;
  
  for line_index=1:length(eng)
      english_line = eng{line_index}(2:length(eng{line_index})-1);
      french_line = fre{line_index}(2:length(fre{line_index})-1);
      
      % handle unique is
      
      for i=1:length(french_line)
          
          % Step 1
          sum_a_prob = 0;
          for j=1:length(english_line)
              % FcountF??
              sum_a_prob = sum_a_prob + t.(english_line{j}).(french_line{i});
          end
          
          for j=1:length(english_line)
              a_prob = t.(english_line{j}).(french_line{i});
              partial_tcount = rdivide(a_prob, sum_a_prob);
              
              % add struct fields if they do not already exist
              if ~isfield(tcount, french_line{i})
                  tcount.(french_line{i}) = struct(); 
              end
              
              if ~isfield(tcount.(french_line{i}), english_line{j})
                  tcount.(french_line{i}).(english_line{j}) = 0;
              end
              
              tcount.(french_line{i}).(english_line{j}) = tcount.(french_line{i}).(english_line{j}) + partial_tcount;
              
              % initialize total field if non-existent
              if ~isfield(total, english_line{j})
                  total.(english_line{j}) = 0;
              end
              
              total.(english_line{j}) = total.(english_line{j}) + partial_tcount;
              
          end
          
      end
      
      
  end
  
  for i=1:length(english_words)
      english_i = english_words{i};
      french_pairs = fieldnames(t.(english_i));
      
      for j=1:length(french_pairs)
          french_i = french_pairs{j};
          
          current_a_prob = tcount.(french_i).(english_i);
          disp(total);
          current_total = total.(english_i);
          disp(current_total);
          updated_a_prob = rdivide(current_a_prob, current_total);
          t.(english_i).(french_i) = updated_a_prob;
      end
  end
  
end
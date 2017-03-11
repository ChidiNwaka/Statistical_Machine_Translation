%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing';
fn_LME       = 'LME';
fn_LMF       = 'LMF';
lm_type      = '';
delta        = 0;
vocabSize    = 28000; 
numSentences = 1000;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
AMFE1K = align_ibm1('/u/cs401/A2_SMT/data/Hansard/Testing', 1000, 10, '1K.mat');
AMFE10K = align_ibm1('/u/cs401/A2_SMT/data/Hansard/Testing', 10000, 10, '10K.mat');
AMFE15K = align_ibm1('/u/cs401/A2_SMT/data/Hansard/Testing', 15000, 10, '15K.mat');
AMFE30K = align_ibm1('/u/cs401/A2_SMT/data/Hansard/Testing', 30000, 10, '30K.mat');

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

% Decode the test sentence 'fre'
eng = decode( fre, LME, AMFE, 'smooth', delta, vocabSize );

% TODO: perform some analysis
% add BlueMix code here 

[status, result] = unix('')
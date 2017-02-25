# csc401A2

This is the second assignment for 401. Thanks. 


Computer Science 401
St. George Campus
13 February 2017
University of Toronto
Homework Assignment #2
Due: Friday, 10 March 2017 at 19h00 (7 PM),
Statistical Machine Translation
TA: Mohamed Abdalla (mohamed.abdalla@mail.utoronto.ca); Hamed Heydari (h.heydari@mail.utoronto.ca)
1
Introduction
This assignment will give you experience in working with n-gram models, smoothing, and statistical ma-
chine translation through word alignment. Knowledge of French is not required.
Your tasks are to build bigram and unigram models of English and French, to smooth their probabilities
using add-? discounting, to build a world-alignment model between English and French using the IBM-1
model, and to use these models to translate French sentences into English with a decoder that we provide.
The programming language for this assignment is Matlab.
2
Background
Canadian Hansard data
The main corpus for this assignment comes from the official records (Hansards) of the 36 th Canadian
Parliament, including debates from both the House of Representatives and the Senate. This corpus is
available at /u/cs401/A2 SMT/data/Hansard/ and has been split into Training/ and Testing/ directories.
This data set consists of pairs of corresponding files (*.e is the English equivalent of the French *.f)
in which every line is a sentence. Here, sentence alignment has already been performed for you. That is,
the n th sentence in one file corresponds to the n th sentence in its corresponding file (e.g., line n in fubar.e
is aligned with line n in fubar.f). Note that this data only consists of sentence pairs; many-to-one,
many-to-many, and one-to-many alignments are not included.
Furthermore, for the purposes of this assignment we have filtered this corpus down to sentences with
between approximately 4 and 15 tokens to simplify the computational requirements of alignment and
decoding. We have also converted the file encodings from ISO-8859-1 to ASCII so as to be usable within
the (old) version of Matlab on CDF. This involved transliterating the original text to remove diacritics,
i.e., accented characters (e.g., Chr ?etien becomes Chretien).
To test your code, you may like to use the samples provided at /u/cs401/A2 SMT/data/Toy.
Apostrophes in strings
In a Matlab string the apostrophe (?) is represented by two apostrophes as in:
>> in = ?The possessor??s possessions?;
in =
The possessor?s possessions
If you write test sentences that contain apostrophes or need to specify an apostrophe in a regular
expression, for example, be sure to use two apostrophes in this way.
Copyright c 2017 Frank Rudzicz. All rights reserved.
1Valid dictionary keys
Matlab?s struct type can in many ways be used as a dictionary or hash, since field names of these structures
can be specified dynamically with string variables. However, Matlab forbids the use of certain characters
(e.g., ?=?) from being part of a valid field name. This can cause problems if you want to use a word that
contains one of these forbidden characters as a field name.
To help alleviate this situation we?ve provided you with /u/cs401/A2 SMT/code/convertSymbols.m
that replaces these illegal symbols with counterparts defined in /u/cs401/A2 SMT/code/csc401 a2 defns.m.
Before these definitions can be used, you must either call that file locally, or make a reference to the relevant
(pre-initialized) structure (e.g., in the file preprocess.m, discussed later), as in
global CSC401 A2 DEFNS
The CSC401 A2 DEFNS structure also defines the start- and end-of-sentence markers SENTSTART, and
SENTEND, respectively. Remember to consider these markers as words when taking your n-gram counts.
Add-? smoothing
Recall that the maximum likelihood estimate of the probability of the current word w t given the previous
word w t?1 is
Count (w t?1 , w t )
P (w t | w t?1 ) =
.
(1)
Count (w t?1 )
Count (w t?1 , w t ) refers to the number of times the word sequence w t?1 w t appears in a training corpus, and
Count(w t?1 ) refers to the number of times the word w t?1 appears in that corpus.
Laplace?s method of add-1 smoothing for n-grams simulates observing otherwise unseen events by
providing probability mass to those unseen events by discounting events we have seen. Although the
simplest of all smoothing methods, in practice this approach does not work well because too much of the
n-gram probability mass is assigned to unseen events, thereby increasing the overall entropy unacceptably.
Add-? smoothing generalizes Laplace smoothing by adding ? to the count of each bigram, where 0 <
? ? 1, and normalizing accordingly. This method is generally attributed to G.J. Lidstone 1 . Given a known
vocabulary V of size V , the probability of the current word w t given the previous word w t?1 in this
model is
Count (w t?1 , w t ) + ?
P (w t | w t?1 ; ?, V ) =
.
(2)
Count (w t?1 ) + ? V
3
Your tasks
1. Preprocess input text [5 marks]
First, implement the following Matlab function:
preprocess(inSentence, language)
that returns a version of the input sentence inSentence that is more amenable to training. For both
languages, separate sentence-final punctuation (sentences have already been determined for you), commas,
colons and semicolons, parentheses, dashes between parentheses, mathematical operators (e.g., +, -, <,
>, =), and quotation marks. When the input language is ?english?, merely re-implement those rules
for separating possessives and clitics that you used in the twtt.py function of Assignment 1. Certain
contractions are required in French, often to eliminate vowel clusters. When the input language is ?french?,
separate the following contractions:
1
Lidstone, G. J. (1920) Note on the general case of the Bayes-Laplace formula for inductive or a priori probabilities.
Transactions of the Faculty of Actuaries 8:182?192.
2Type
Singular definite article
(le, la)
Single-consonant words
ending in e-?muet? (e.g.,
?dropped?-e ce, je)
que
Conjunctions
puisque and lorsque
Modification
Separate leading l? from
concatenated word
Separate leading consonant
and apostrophe from
concatenated word
Separate leading qu? from
concatenated word
Separate following on or il
Example
l?election ? l? election
je t?aime ? je t? aime,
j?ai ? j? ai
qu?on ? qu? on,
qu?il ? qu? il
puisqu?on ? puisqu? on,
lorsqu?il ? lorsqu? il
Any words containing apostrophes not encapsulated by the above rules can be left as-is. Additionally,
the following French words should not be separated: d?abord, d?accord, d?ailleurs, d?habitude.
A template of this function has been provided for you at /u/cs401/A2 SMT/code/preprocess.m. Make
your changes to a copy of this file and submit your version.
2. Compute n-gram counts [15 marks]
Next, implement a function to simply count all unigrams and bigrams in the preprocessed training data,
namely:
LM = lm train(dataDir, language, fn LM)
that returns a special language model structure, LM, defined below. This function trains on all of the data
files in dataDir that end in either ?e? for English or ?f? for French (which is specified in the argument
language) and saves the structure that it returns in the filename fn LM (it should take about 5MB).
The structure returned by this function should be called ?LM? and must have two fields: ?uni? and ?bi?,
each of which holds structures which incorporate unigram and bigram counts, respectively. Remember
that you can dynamically create structures in Matlab. The fieldnames (i.e. keys) to the ?uni? structure are
words and the values of those fields are the total counts of those words in the training data. The fieldnames
to the ?bi? structure are words (w t?1 ) and their fields are structures. The fieldnames of those structures
are also words (w t ) and the values of those fields are the total counts of ?w t?1 w t ? in the training data.
E.g.,
>> LM.uni.word = 5 % the word ?word? appears 5 times in training
>> LM.bi.word.bird = 2 % the bigram ?word bird? appears twice in training
A template of this function has been provided for you at /u/cs401/A2 SMT/code/lm train.m. Note
that this template calls preprocess. If this procedure is giving you errors of the type Warning: ?...?
exceeds MATLAB?s maximum name length of 63 characters..., that is a sign that you need to fix
tokenization in your preprocessing function.
Make your changes to a copy of the lm train.m template and submit your version. Train two language
models, one for English and one for French, on the data at /u/cs401/A2 SMT/data/Hansard/Training/.
You will use these models for subsequent tasks.
33. Compute log-likelihoods and add-? log-likelihoods [20 marks]
Now implement a function to compute the log-likelihoods of test sentences, namely:
logProb = lm prob(sentence, LM, type, delta, vocabSize) .
This function takes sentence (a previously preprocessed string) and a language model LM (as produced
by lm train). If the argument type is either missing or is an empty string (??), this function returns the
maximum-likelihood estimate of the sentence. If the argument type is ?smooth?, this function returns a
?-smoothed estimate of the sentence. In the case of smoothing, the arguments delta and vocabSize must
also be specified (where 0 < ? ? 1).
t w t+1 )
When computing your MLE estimate, if you encounter the situation where Count(w
= 0/0, then
Count(w t )
assume that the probability P (w t+1 | w t ) = 0 or, equivalently, log P (w t+1 | w t ) = ??. Infinity in Matlab
is represented by Inf. Use log base 2 (i.e. log2()).
A template of this function has been provided for you at /u/cs401/A2 SMT/code/lm prob.m. Make
your changes to a copy of the lm prob.m template and submit your version.
We also provide you with the function /u/cs401/A2 SMT/code/perplexity.m, which returns the per-
plexity of a test corpus given a language model. You do not need to modify this function. Using the language
models learned in Task 2, compute the perplexity of the data at /u/cs401/A2 SMT/data/Hansard/Testing/
for each language and for both the MLE and add-? versions. Try at least 3 to 5 different values of ? ac-
cording to your judgment. Submit a report, Task3.txt, which summarizes your findings. Your report can
additionally include experiments on the log-probabilities of individual sentences.
4. Implement IBM-1 [25 marks]
Now implement the IBM-1 algorithm to learn word alignments between English and French words, namely:
AM = align ibm1(trainDir, numSentences, maxIter, fn AM).
This function trains on the first numSentences read in data files from trainDir. The parameter maxIter
specifies the maximum number of times the EM algorithm iterates before being terminated. This function
returns a specialized alignment model structure, AM, in which AM.eng word.fre word holds the probability
(not log probability) of the word eng word aligning to fre word. In this sense, AM is essentially the t
distribution from class, e.g.,
>> AM.bird.oiseau = 0.8 % t(oiseau | bird) = 0.8
Here, we will use a simplified version of IBM-1 in which we ignore the NULL word and we ignore align-
ments where an English word would align with no French word, as discussed in class. So, the probability
of an alignment A of a French sentence F , given a known English sentence E is
len F
P (A, F | E) =
t(f j | e a j )
j=1
where a j is the index of the word in E which is aligned with the j th word in F and len F is the number of
tokens in the French sentence. Since we are only using IBM-1, we employ the simplifying assumption that
every alignment is equally likely.
Note: The na ??ve approach to initializing AM is to have a uniform distribution over all possible English
(e) and French (f) words, i.e., AM.e.f = 1/ V F , where V F is the size of the French vocabulary. Doing
so, however, will consume too much memory and computation time. Instead, you can initialize AM.e
uniformly over only those French words that occur in corresponding French sentences. For example,
4the house
la maison
given only the training sentence pairs house of commons chambre des communes , you would initialize
Andromeda galaxy
galaxie d?Andromede
the structure AM.house.la = 0.2, AM.house.maison = 0.2, AM.house.chambre = 0.2, AM.house.des
= 0.2, AM.house.communes = 0.2. There would be no probability of generating galaxie from house.
Note that you can force AM.SENTSTART.SENTSTART = 1 and AM.SENTEND.SENTEND = 1.
A template of this function has been provided for you at /u/cs401/A2 SMT/code/align ibm1.m. You
will notice that we have suggested a general structure of empty helper functions here, but you are free to
implement this function as you wish, as long as it meets with the specifications above. Make your changes
to a copy of the align ibm1.m template and submit your version.
5. Translate and evaluate the test data [10 marks]
You will now produce your own translations, obtain reference translations from Google and the Hansards,
and use the latter to evaluate the former, with a BLEU score. This will all be done in the file evalAlign.m
(there is a very sparse template of this file at /u/cs401/A2 SMT/code/).
To decode, we are providing the function
english = decode2( french, LM, AM, lmtype, delta, vocabSize ),
at /u/cs401/A2 SMT/code/decode2.m. Here, french is a preprocessed French sentence, LM and AM are
your English language model from Task 2 and your alignment model trained from Task 4, respectively, and
lmtype, delta, and vocabSize parameterize smoothing, as before in Task 3. You do not need to change
the decode2 function, but you may (see the Bonus section, below).
For evaluation, translate the 25 French sentences in /u/cs401/A2 SMT/data/Hansard/Testing/Task5.f
with the decode2 function and evaluate them using corresponding reference sentences, specifically:
1. /u/cs401/A2 SMT/data/Hansard/Testing/Task5.e, from the Hansards.
2. /u/cs401/A2 SMT/data/Hansard/Testing/Task5.google.e, Google?s translations of the French phrases 2 .
To evaluate each translation, use the BLEU score from lecture 6-2, i.e.,
BLEU = BP C × (p 1 p 2 . . . p n ) (1/n)
(3)
Repeat this task with at least four alignment models (trained on 1K, 10K, 15K, and 30K sentences,
respectively) and with three values of n in the BLEU score (i.e., n = 1, 2, 3). You should therefore have
25 × 4 × 3 BLEU scores in your evaluation. Write a short subjective analysis of how the different references
differ from each other, and whether using more than 2 of them might be better (or worse).
In all cases, you can use the MLE language model (i.e., specify lmtype = ??). Optionally, you can try
additional alignment models, smoothed language model with varying ?, or other test data from other files
in /u/cs401/A2 SMT/data/Hansard/Testing/.
Submit your evaluation procedure, evalAlign.m, along with a report, Task5.txt, which summarizes
your findings. If you make any changes to any other files, submit those files as well.
Bonus [up to 15 marks]
We will give bonus marks for innovative work going substantially beyond the minimal requirements. Your
overall mark for this assignment cannot exceed 100%.
You may decide to pursue any number of tasks of your own design related to this assignment, although
you should consult with the instructor or the TA before embarking on such exploration. Certainly, the
rest of the assignment takes higher priority. Some ideas:
2
See https://developers.google.com/api-client-library/python/apis/translate/v2, but be prepared to pay.
5? Read about Good-Turing smoothing in section 6.2.5 of Manning and Sch ?
utze?s Foundations of Sta-
tistical Natural Language Processing. This method is more sophisticated than add-? smoothing and
ensures that less of the overall probability mass is assigned to unseen events. This works much better
in practice than add-?. You may implement this method of smoothing and re-run the experiments
in Task 3, above. Submit your code and an associated discussion.
? Implement the IBM-2 model of word-alignment, otherwise replicating Task 4 above. Ideally, translate
the test data using this model and compute the error, as you did for Task 5. How does this model
compare to IBM-1? Submit your code and an associated discussion.
? We have not considered the null word when performing alignments. Re-implement the IBM-1 align-
ment model to include null words and the possibility that no English word aligns with a French word
(or vice versa). Submit your code and an associated discussion.
? Perform substantial data analysis of the error trends observed in each method you implement. This
must go well beyond the basic discussion already included in the assignment. Submit a report.
? The decoder we use here is extremely simple and incomplete. You can write your own decoder that
attempts to find e ? = arg max e P (e | f ) using a heuristic A ? search, for example. Alternatively, what
happens if you weight the contributions of the alignment and the language model to the overall
probability? Section 25.8 of the Jurafsky & Martin textbook offers some ideas on how to improve
the decoder. Submit your code and an associated discussion, comparing the decoded results to those
performed with the default decoder.
4
General specification
We will test your code on different training and testing documents in addition to those specified above.
Where possible, do not hardwire directory names into your code. As part of grading your assignment,
the grader may run your programs using test harness Matlab scripts. It is therefore important that each
of your programs precisely meets all the specifications and formatting requirements, including program
arguments and file names.
If a program uses a file or helper script name that is specified within the program, it must read it
either from the directory in which the program is being executed, or it must read it from a subdirectory
of /u/cs401 whose path is completely specified in the program. Do not hardwire the absolute address of
your home directory within the program; the grader does not have access to this directory.
All your programs must contain adequate internal documentation to be clear to the graders. External
documentation is not required.
64.1
Submission requirements
This assignment is submitted electronically. You should submit:
1. All your code for preprocess.m, lm train.m, lm prob.m, align ibm1.m, and evalAlign.m, along
with any other source files to which you made changes or which are necessary to run your code in
Matlab on CDF.
2. Your alignment model trained on 1k sentences from /u/cs401/A2 SMT/data/Hansard/Training/,
dumped in file am.mat.
3. Your reports Task3.txt and Task5.txt.
4. Any material submitted towards a bonus mark. This should be limited to code, results, and reports
as text files.
5. Your ID file as described in Assignment 1. A template of ID is available on the course web page.
You do not need to hand in your language models or other temporary files. The electronic
submission must be made from the CDF submission site. Do not tar or compress your files, and do not
place your files in subdirectories.
5
Using your own computer
If you want to do some or all of this assignment on your laptop or other computer, you will have to do
the extra work of downloading and installing the requisite software and data. You take on the risk that
your computer might not be adequate for the task. You are strongly advised to upload regular backups
of your work to CDF, so that if your machine fails or proves to be inadequate, you can immediately
continue working on the assignment at CDF. When you have completed the assignment, you should try
your programs out on CDF to make sure that they run correctly there. A submission that does not
work on CDF will get zero marks.
6
Suggestions
This assignment uses a simplified version of an alignment model which itself makes several major simplifying
assumptions and, as such, the results of the decoder will not be representative of the state-of-the-art in
statistical machine translation. You will generally be marked on how well you understand the underlying
concepts and algorithms. This approach was chosen for this assignment in order to give you a relative
reprieve in the mid-term workload. However, if you have the time you are highly encouraged to pursue
bonus work as indicated above. Exploring more complex models is not only interesting, but will give you
a fuller perspective on the techniques used in machine translation.
The following dates are suggestions as to how to spread out the work for this assignment. These dates
may not be applicable to you personally and they are not required deadlines. However, it?s a good idea to
try to spread things out so you don?t have to rush at the end.
Task 1 20 February
Task 2 24 February
Task 3 1 March
Task 4 6 March
Task 5 10 March
7

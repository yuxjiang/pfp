function [tfidf] = pfp_tfidf(X)
    %PFP_TFIDF
    %
    %   [tfidf] = PFP_TFIDF(X);
    %
    %       Transforms a word count matrix to be a tf-idf matrix.
    %
    % Input
    % -----
    % [double] (probably sparse)
    % X:    The word count matrix. I.e., X(i,j) is the word count for word(j) in
    %       document(i). All entries must be non-negative integers.
    %
    % Output
    % ------
    % [double]
    % tfidf:    The transformed tf-idf matrix.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_tfidf:InputCount', 'Expected 1 input.');
    end

    % X
    validateattributes(X, {'double'}, {'nonnegative', 'integer'}, '', 'X', 1);
    % }}}

    % compute tf-idf {{{
    tf = X ./ sum(X, 2);
    occurred = any(X, 1);
    idf = log(size(X, 1) ./ sum(X(:, occurred) > 0, 1));
    tfidf = tf .* idf;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 03 May 2017 08:52:51 PM E

function [C] = pfp_cosinesim(X, Y)
    %PFP_COSINESIM Cosine similarity
    %
    %   [C] = PFP_COSINESIM(X, Y);
    %
    %       Returns the pairwise cosine similarity between rows of X and Y.
    %
    % Input
    % -----
    % [double]
    % X:    An n-by-k data matrix. (One instance per row.)
    %
    % [double]
    % Y:    An m-by-k data matrix.
    %
    % Output
    % ------
    % [double]
    % C:    n-by-m cosine similarity matrix between data instances.

    % check input {{{
    if nargin ~= 2
        error('pfp_cosinesim:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    C = (X * Y') ./ (sqrt(sum(X.^2,2)) * sqrt(sum(Y.^2,2))');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Fri 17 Feb 2017 05:43:51 AM E

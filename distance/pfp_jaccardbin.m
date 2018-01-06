function [J] = pfp_jaccardbin(X, Y)
    %PFP_JACCARDBIN Jaccard index binary
    %
    %   [J] = PFP_JACCARDBIN(X, Y);
    %
    %       Returns the pairwise Jaccard index (in the binary case) between rows
    %       of X and Y.
    %
    % Remark
    % ------
    % The binary case Jaccard index assumes the input X and Y are indicator for
    % the present/absent of an element in the set. See also pfp_jaccard.m for
    % the definition on real vectors (the same as 'jaccard' used in Matlab
    % built-in function: pdist)
    %
    % Input
    % -----
    % [logical]
    % X:    An n-by-k set indicator matrix. (One instance per row.)
    %       k is the number of elements of the union of sets.
    %       n is the number of instances.
    %       X(i, j) is true if element(j) is presented in set(i).
    %
    % [logical]
    % Y:    An m-by-k set indicator matrix.
    %
    % Output
    % ------
    % [double]
    % J:    n-by-m Jaccard index matrix.
    %
    % See also
    % --------
    % [>] pfp_jaccard.m

    % check input {{{
    if nargin ~= 2
        error('pfp_jaccardbin:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'logical'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'logical'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    n = size(X, 1);
    m = size(Y, 1);
    J = zeros(n, m);
    for i = 1 : n
        J(i, :) = (sum(bsxfun(@and, X(i,:), Y), 2) ./ sum(bsxfun(@or, X(i,:), Y), 2))';
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Fri 17 Feb 2017 06:02:51 AM E

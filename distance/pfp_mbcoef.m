function [M] = pfp_mbcoef(X, Y)
    %PFP_MBCOEF Maryland bridge coefficient
    %
    %   [M] = PFP_MBCOEF(X, Y);
    %
    %       Calculates the pairwise Maryland bridge coefficient between rows of
    %       X and Y.
    %
    % Definition
    % ----------
    % "Maryland bridge coefficient" of two sets A and B, is defined as:
    % M(A, B) = |intersect(A, B)| / 2|A| + |intersect(A, B)| / 2|B|
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
    % M:    n-by-m Maryland bridge coefficient matrix.

    % check inputs {{{
    if nargin ~= 2
        error('pfp_mbcoef:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'logical'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'logical'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % compute Maryland bridge coefficient {{{
    X = double(X);
    Y = double(Y);
    cX = 2 * full(sum(X, 2));   % n-by-1 column vector (cardinality)
    cY = 2 * full(sum(Y, 2))';  % 1-by-m column vector (cardinality)
    XY = full(X * Y'); % n-by-m matrix
    M = bsxfun(@rdivide, XY, cX) + bsxfun(@rdivide, XY, cY);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Thu 16 Feb 2017 05:03:23 PM E

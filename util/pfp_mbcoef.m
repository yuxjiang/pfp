function [MB] = pfp_mbcoef(X, Y)
    %PFP_MBCOEF Maryland bridge coefficient
    %
    % [MB] = PFP_MBCOEF(X);
    %
    %   Calculates the pairwise Maryland bridge coefficient between rows in X.
    %
    % [MB] = PFP_MBCOEF(oa, list);
    %
    %   Calculates the pairwise Maryland bridge coefficient between rows in X
    %   and Y.
    %
    % Definition
    % ----------
    % "Maryland bridge coefficient" of two sets A and B, is defined as:
    % MB(A, B) = |intersect(A, B)| / 2|A| + |intersect(A, B)| / 2|B|
    %
    % Input
    % -----
    % (required)
    % [logical]
    % X:    An n-by-k set indicator matrix. (One instance per row.)
    %       k is the number of elements of the union of sets.
    %       n is the number of instances.
    %       X(i, j) is true if element(j) is presented in set(i).
    %
    % (optional)
    % [logical]
    % Y:    An m-by-k set indicator matrix.
    %
    % Output
    % ------
    % [double]
    % MB:   n-by-n (when Y is not presented) or
    %       n-by-m (when Y is presented) Maryland bridge coefficient matrix.

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_mbcoef:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        Y = X;
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
    MB = bsxfun(@rdivide, XY, cX) + bsxfun(@rdivide, XY, cY);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:34:17 PM E

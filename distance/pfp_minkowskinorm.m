function [D] = pfp_minkowskinorm(X, Y, p)
    %PFP_MINKOWSKINORM Minkowski distance (normalized)
    %
    %   [D] = PFP_MINKOWSKINORM(X, Y, p);
    %
    %       Returns the normalized pairwise Minkowski distance between rows of X
    %       and Y.
    %
    % Input
    % -----
    % [double]
    % X:    An n-by-k data matrix. (One instance per row.)
    %       k is the number of features (variables)
    %       n is the number of instances.
    %
    % [double]
    % Y:    An m-by-k data matrix.
    %
    % [double]
    % p:    The power. default: 2.
    %       Note for special cases:
    %       p = 1   --> city block
    %       p = 2   --> Euclidean
    %       p = Inf --> Chebychev
    %
    % Output
    % ------
    % [double]
    % D:    n-by-m Minkowski distance matrix.
    %
    % Dependency
    % ----------
    % [>] pfp_minkowski.m

    % check input {{{
    if nargin ~= 3
        error('pfp_minkowski:InputCount', 'Expected 3 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);

    % p
    validateattributes(p, {'double'}, {'positive'}, '', 'p', 3);
    % }}}

    % calculation {{{
    nX = cellfun(@(x) norm(x, p), num2cell(X, 2));
    nY = cellfun(@(x) norm(x, p), num2cell(Y, 2))';
    D = pfp_minkowski(X, Y, p) ./ (nX + nY);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 27 Sep 2017 03:13:01 PM E

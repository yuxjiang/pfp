function [D] = pfp_minkowski(X, Y, p)
    %PFP_MINKOWSKI Minkowski distance
    %
    %   [D] = PFP_MINKOWSKI(X, Y, p);
    %
    %       Returns the pairwise Minkowski distance between rows of X and Y.
    %
    % Remark
    % ------
    % This function is simply a wrapper of pdist2.
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
    D = pdist2(X, Y, 'minkowski', p);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 27 Sep 2017 03:10:37 PM E

function [D] = pfp_hellinger(X, Y)
    %PFP_HELLINGER Hellinger distance
    %
    %   [D] = PFP_HELLINGER(X, Y);
    %
    %       Returns the pairwise Hellinger distance between rows of X and Y.
    %       Note that each row of X (Y) is considered as a probability mass
    %       function properly aligned over their support.
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
    %       Note that both X and Y must be non-negative.
    %
    % Output
    % ------
    % [double]
    % D:    n-by-m Hellinger distance matrix.

    % check input {{{
    if nargin ~= 2
        error('pfp_hellinger:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty', 'nonnegative'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'nonnegative', 'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % calculation {{{
    X = sqrt(X);
    Y = sqrt(Y);
    n = size(X, 1);
    m = size(Y, 1);
    D = zeros(n, m);
    for i = 1 : n
        D(i, :) = sqrt(sum((X(i,:) - Y).^2, 2))';
    end
    D = (1/sqrt(2)) .* D;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Mon 17 Apr 2017 04:05:38 PM E

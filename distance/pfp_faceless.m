function [D] = pfp_faceless(X, Y, p)
    %PFP_FACELESS Faceless distance
    %
    %   [D] = PFP_FACELESS(X, Y);
    %
    %       Returns the pairwise faceless distance between rows of X and Y.
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
    % p:    The power.
    %
    % Output
    % ------
    % [double]
    % D:    n-by-m faceless distance matrix.

    % check input {{{
    if nargin ~= 3
        error('pfp_faceless:InputCount', 'Expected 3 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);

    % p
    validateattributes(p, {'double'}, {'positive'}, '', 'p', 3);
    % }}}

    % calculation {{{
    n = size(X, 1);
    m = size(Y, 1);
    D = zeros(n, m);
    if isinf(p)
        for i = 1 : n
            T = repmat(X(i,:), m, 1) - Y;
            D(i, :) = max(sum(max(0, T), 2)', sum(max(0, -T), 2)');
        end
    else
        for i = 1 : n
            T = repmat(X(i,:), m, 1) - Y;
            D(i, :) = ((sum(max(0, T), 2).^p + sum(max(0, -T), 2).^p).^(1/p))';
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 22 Feb 2017 05:07:11 PM E

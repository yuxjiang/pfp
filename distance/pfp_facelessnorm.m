function [D] = pfp_facelessnorm(X, Y, p)
    %PFP_FACELESSNORM Faceless distance normalized
    %
    %   [D] = PFP_FACELESSNORM(X, Y);
    %
    %       Returns the pairwise normalized faceless distance between rows of X
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
    % p:    The power.
    %
    % Output
    % ------
    % [double]
    % D:    n-by-m normalized faceless distance matrix.

    % check input {{{
    if nargin ~= 3
        error('pfp_facelessnorm:InputCount', 'Expected 3 inputs.');
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
    absX = abs(X);
    absY = abs(Y);
    I_zero_X = all(X == 0, 2);
    I_zero_Y = all(Y == 0, 2);
    if isinf(p)
        for i = 1 : n
            T = repmat(X(i,:), m, 1) - Y;
            absYT = max(absY, abs(T));
            D(i, :) = max(sum(max(0, T), 2)', sum(max(0, -T), 2)') ./ sum(max(repmat(absX(i,:),m,1), absYT), 2)';
        end
    else
        for i = 1 : n
            T = repmat(X(i,:), m, 1) - Y;
            absYT = max(absY, abs(T));
            D(i, :) = ((sum(max(0, T), 2).^p + sum(max(0, -T), 2).^p).^(1/p))' ./ sum(max(repmat(absX(i,:),m,1), absYT), 2)';
        end
    end

    % patch for x = y = 0
    D(I_zero_X, I_zero_Y) = 0;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Mon 17 Apr 2017 07:24:21 PM E

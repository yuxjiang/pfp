function [D] = pfp_totalvar(X, Y)
    %PFP_TOTALVAR Total variation
    %
    %   [D] = PFP_TOTALVAR(X, Y);
    %
    %       Returns the pairwise "total variation" between rows of X and Y.
    %       Note that each row of X (Y) is considered as a discrete function
    %       defined on a fixed finite domain. This function thus compute the
    %       total variation as D(i,j) = TV(X(i,:) - Y(j,:)).
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
    % Output
    % ------
    % [double]
    % D:    n-by-m total variation matrix.

    % check input {{{
    if nargin ~= 2
        error('pfp_totalvar:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % calculation {{{
    n = size(X, 1);
    m = size(Y, 1);
    D = zeros(n, m);
    for i = 1 : n
        T = X(i,:) - Y;
        D(i, :) = sum(abs(T(:,2:end) - T(:,1:end-1)), 2)';
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Mon 17 Apr 2017 04:59:21 PM E

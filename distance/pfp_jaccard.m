function [D] = pfp_jaccard(X, Y)
    %PFP_JACCARD Jaccard distance
    %
    %   [D] = PFP_JACCARD(X, Y);
    %
    %       Returns the pairwise Jaccard distance between rows of X and Y.
    %
    % Remark
    % ------
    % This function is not as fast as pdist (without Y present), so use the
    % built-in pdist with distance = 'jaccard' in that case.
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
    % D:    n-by-m Jaccard distance matrix.
    %
    % See also
    % --------
    % [>] pfp_jaccardbin.m

    % check input {{{
    if nargin ~= 2
        error('pfp_jaccard:InputCount', 'Expected 2 inputs.');
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
    T = zeros(size(Y));
    for i = 1 : n
        T = bsxfun(@ne, X(i,:), zeros(size(Y))) | Y ~= 0;
        D(i, :) = sum(bsxfun(@ne, X(i,:), Y) & T, 2)' ./ sum(T, 2)';
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Tue 18 Apr 2017 12:13:02 AM E

function [D] = pfp_hamming(X, Y)
    %PFP_HAMMING Hamming distance
    %
    %   [D] = PFP_HAMMING(X, Y);
    %
    %       Returns the pairwise Hamming distance between rows of X and Y.
    %
    % Remark
    % ------
    % This function is not as fast as pdist (without Y present), so use the
    % built-in pdist with distance = 'hamming' in that case.
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
    % D:    n-by-m Hamming distance matrix.

    % check input {{{
    if nargin ~= 2
        error('pfp_hamming:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % calculation {{{
    n = size(X, 1);
    k = size(X, 2);
    m = size(Y, 1);
    D = zeros(n, m);
    for i = 1 : n
        D(i, :) = sum(bsxfun(@ne, X(i,:), Y), 2)' ./ k;
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Tue 18 Apr 2017 12:12:47 AM E

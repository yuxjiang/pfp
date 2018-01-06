function [X] = pfp_unitnorm(X)
    %PFP_UNITNORM
    %
    %   [X] = PFP_UNITNORM(X);
    %
    %       Normalises each row of the data matrix so as to make each of them
    %       having length 1.
    %
    % Remark
    % ------
    % For rows with tiny length (<1e-8), they are forced to be all zeros.
    %
    % Input
    % -----
    % [double]
    % X:    The n-by-m data matrix.
    %
    % Output
    % ------
    % [double]
    % X:    The normalized data matrix.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_unitnorm:InputCount', 'Expected 1 input.');
    end
    
    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);
    % }}}

    % normalization {{{
    tol = 1e-8;
    L = sqrt(sum(X .^ 2, 2));
    tiny_length = find(L < tol);
    if ~isempty(tiny_length)
        warning('pfp_unitnorm:SMLVEC', 'Some rows are forced to be zero');
        L(tiny_length) = 1;
        X = bsxfun(@rdivide, X, L);
        X(tiny_length, :) = 0;
    else
        X = bsxfun(@rdivide, X, L);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 23 Aug 2017 12:37:49 PM E

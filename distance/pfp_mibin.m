function [I] = pfp_mibin(X, Y)
    %PFP_MIBIN Mutual information binary
    %
    %   [I] = PFP_MIBIN(X, Y);
    %
    %       Returns the pairwise mutual information of (columns of) X and Y.
    %
    % Note
    % ----
    % 1. Assumes X (and/or Y) is a data matrix consists of n observations of k
    %    binary random variables.
    % 2. This function uses log base 2, so the output unit is "bit".
    %
    % Input
    % -----
    % [logical]
    % X:    An n-by-k binary matrix
    %
    % [logical]
    % Y:    An n-by-l binary matrix
    %
    % Output
    % ------
    % [double]
    % I:    k-by-l mutual information matrix.

    % check input {{{
    if nargin ~= 2
        error('pfp_mibin:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'logical'}, {'nonempty'}, '', 'X', 1);
    n = size(X, 1);

    % Y
    validateattributes(Y, {'logical'}, {'nrows', n}, '', 'Y', 2);
    % }}}

    % compute mutual information {{{
    x0 = double(X == 0);
    x1 = double(X == 1);
    y0 = double(Y == 0);
    y1 = double(Y == 1);

    % case x = 0, y = 0 {{{
    Px   = sum(x0) / n;
    Py   = sum(y0) / n;
    Pxy  = (x0' * y0) / n;
    PxPy = Px' * Py;

    I00 = Pxy .* log2(Pxy ./ PxPy);
    I00(isnan(I00)) = 0; % set (0 * -Inf) to 0 for those Pxy = 0
    % }}}

    % case x = 0, y = 1 {{{
    Px   = sum(x0) / n;
    Py   = sum(y1) / n;
    Pxy  = (x0' * y1) / n;
    PxPy = Px' * Py;

    I01 = Pxy .* log2(Pxy ./ PxPy);
    I01(isnan(I01)) = 0;
    % }}}

    % case x = 1, y = 0 {{{
    Px   = sum(x1) / n;
    Py   = sum(y0) / n;
    Pxy  = (x1' * y0) / n;
    PxPy = Px' * Py;

    I10 = Pxy .* log2(Pxy ./ PxPy);
    I10(isnan(I10)) = 0;
    % }}}

    % case x = 1, y = 1 {{{
    Px   = sum(x1) / n;
    Py   = sum(y1) / n;
    Pxy  = (x1' * y1) / n;
    PxPy = Px' * Py;

    I11 = Pxy .* log2(Pxy ./ PxPy);
    I11(isnan(I11)) = 0;
    % }}}

    % combine {{{
    I = I00 + I01 + I10 + I11;
    % }}}
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Thu 16 Feb 2017 05:04:39 PM E

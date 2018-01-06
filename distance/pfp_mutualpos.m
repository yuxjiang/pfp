function [P] = pfp_mutualpos(X, Y)
    %PFP_MUTUALPOS Mutual positive
    %
    %   [P] = PFP_MUTUALPOS(X, Y);
    %
    %       Returns the pairwise mutual positive of (columns) of X and Y.
    %
    % Definition
    % ----------
    % [Mutual positive] is defined as follows
    %                   p(x=1, y=1)
    %  MP(x, y) = log ---------------
    %                  p(x=1) p(y=1)
    %
    % Note
    % ----
    % 1. Assumes X (and/or Y) is a data matrix consists of n observations of k
    %    binary random variables.
    % 2. This function uses log base 2, so the output unit is "bit".
    % 3. All -Inf and NaN will be forced to zero to make the output matrix
    %    sparse, since in most cases we only care about the real value outputs.
    %
    % Input
    % -----
    % [logical]
    % X:    An n-by-k binary matrix.
    %
    % [logical]
    % Y:    An n-by-l binary matrix.
    %
    % Output
    % ------
    % [double]
    % P:    k-by-l mutual positive matrix.

    % check input {{{
    if nargin ~= 2
        error('pfp_mutualpos:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'logical'}, {'nonempty'}, '', 'X', 1);
    n = size(X, 1);

    % Y
    validateattributes(Y, {'logical'}, {'nrows', n}, '', 'Y', 2);
    % }}}

    % compute "mutual positive" {{{
    X = double(X ~= 0);
    Y = double(Y ~= 0);

    Px   = sum(X, 1) / n;
    Py   = sum(Y, 1) / n;
    Pxy  = sparse((X' * Y) / n);
    PxPy = sparse(Px' * Py);
    clear X Y

    P = log2(Pxy ./ PxPy);
    clear Pxy PxPy

    % make it more sparse, clear non-related results
    P(isnan(P)) = 0;
    P(isinf(P)) = 0;

    if numel(P) < 1e6
        P = full(P);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Thu 16 Feb 2017 05:06:09 PM E

function [D] = pfp_corrdist(X, Y)
    %PFP_CORRDIST Correlation distance
    %
    %   [D] = PFP_CORRDIST(X, Y);
    %
    %       Returns the pairwise correlation distance between rows of X and Y.
    %
    % Input
    % -----
    % [double]
    % X:    An n-by-k data matrix. (One instance per row.)
    %
    % [double]
    % Y:    An m-by-k data matrix.
    %
    % Output
    % ------
    % [double]
    % D:    n-by-m correlation distance matrix between data instances.

    % check input {{{
    if nargin ~= 2
        error('pfp_corrdist:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    D = 1 - corr(X', Y');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Fri 17 Feb 2017 05:49:11 AM E

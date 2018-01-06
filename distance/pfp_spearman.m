function [D] = pfp_spearman(X, Y)
    %PFP_SPEARMAN Correlation distance
    %
    %   [D] = PFP_SPEARMAN(X, Y);
    %
    %       Returns the pairwise Spearman distance between rows of X and Y.
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
        error('pfp_spearman:InputCount', 'Expected 2 inputs.');
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    D = 1 - corr(tiedrank(X'), tiedrank(Y'));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Fri 17 Feb 2017 04:28:44 PM E

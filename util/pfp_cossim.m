function [C] = pfp_cossim(X, Y)
    %PFP_COSSIM Cosine similarity
    %
    % [C] = PFP_COSSIM(X);
    %
    %   Returns the pairwise cosine similarity between rows of X's.
    %
    % [C] = PFP_COSSIM(X, Y);
    %
    %   Returns the pairwise cosine similarity between rows of X's and Y's.
    %
    % Input
    % -----
    % (required)
    % [double]
    % X:    An n1-by-k data matrix. (One instance per row.)
    %
    % (optional)
    % [double]
    % Y:    An n2-by-k data matrix.
    %
    % Output
    % ------
    % [double]
    % C:    The n1-by-n2 cosine similarity matrix between data instances.

    % check input {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_cossim:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        Y = X;
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'double'}, {'ncol', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    nrmX = loc_get_norm(X);
    if nargin == 2 % Y is given
        nrmY = loc_get_norm(Y);
    else
        nrmY = nrmX;
    end
    C = (X * Y') ./ (nrmX * nrmY');
    % }}}
end

% function: loc_get_norm {{{
function [nA] = loc_get_norm(A)
    nA = sqrt(sum(A .^ 2, 2));
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:28:30 PM E

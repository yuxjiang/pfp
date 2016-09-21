function [J] = pfp_jaccard(X, Y)
    %PFP_JACCARD Jaccard index
    %
    % [J] = PFP_JACCARD(X);
    %
    %   Returns the pairwise Jaccard index between rows of X's.
    %
    % [J] = PFP_JACCARD(X, Y);
    %
    %   Returns the pairwise Jaccard index between rows of X's and Y's.
    %
    % Input
    % -----
    % (required)
    % [logical]
    % X:    An n-by-k set indicator matrix. (One instance per row.)
    %       k is the number of elements of the union of sets.
    %       n is the number of instances.
    %       X(i, j) is true if element(j) is presented in set(i).
    %
    % (optional)
    % [logical]
    % Y:    An m-by-k set indicator matrix.
    %
    % Output
    % ------
    % [double]
    % J:    n-by-n (when Y is not presented) or
    %       n-by-m (when Y is presented) Jaccard index matrix.

    % check input {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_jaccard:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        Y = X;
    end

    % X
    validateattributes(X, {'logical'}, {'nonempty'}, '', 'X', 1);

    % Y
    validateattributes(Y, {'logical'}, {'ncols', size(X, 2)}, '', 'Y', 2);
    % }}}

    % computation {{{
    X = double(X);
    Y = double(Y);
    J = (X * Y') ./ loc_get_uc_matrix(X, Y);
    % }}}
end

% function: loc_get_uc_matrix {{{
function [uc] = loc_get_uc_matrix(X, Y)
    % get union count matrix
    k  = size(X, 1);
    uc = zeros(k, k);

    for i = 1 : k
        for j = i : k
            c = sum((X(i,:) + Y(j,:)) > 0);
            uc(i, j) = c;
            uc(j, i) = c;
        end
    end
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:33:18 PM E

function [bx] = pfp_bincat(cx, C)
    %PFP_BINCAT
    %
    %   [bx] = PFP_BINCAT(cx);
    %   [bx] = PFP_BINCAT(cx, C);
    %
    %       Binarizes a column of categorical feature.
    %
    % Input
    % -----
    % (required)
    % [double]
    % cx:   An n-by-1 column vector of a categorical feature.
    %
    % (optional)
    % [double]
    % C:    An array of all possible (size m) values in the category.
    %       default: unique(cx)
    %
    % Output
    % ------
    % [double]
    % bx:   An n-by-m 0/1 matrix, with m being the number of possible values in
    %       the category.

    % check inputs {{{
    if nargin < 1 && nargin > 2
        error('pfp_bincat:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        C = unique(cx);
    end

    % cx
    validateattributes(cx, {'double'}, {'vector', 'ncols', 1}, '', 'cx', 1);

    % C
    validateattributes(C, {'double'}, {'vector'}, '', 'C', 2);
    [found, index] = ismember(cx, C);
    if ~all(found)
        error('pfp_bincat:InputErr', 'cx has additional values that are not in C.');
    end
    % }}}

    % conversion {{{
    n = numel(cx); % number of data points
    m = numel(C);  % size of category
    offset = m .* (0:(n-1))';
    index  = reshape(index, [], 1);
    bx = zeros(n*m, 1);
    bx(offset + index) = 1;
    bx = reshape(bx, m, n)';
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 22 Feb 2017 11:18:51 PM E

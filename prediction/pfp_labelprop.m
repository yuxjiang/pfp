function [L] = pfp_labelprop(T, Y, thresh)
    %PFP_LABELPROP Label propagation
    %
    % [L] = PFP_LABELPROP(T, Y);
    % [L] = PFP_LABELPROP(T, Y, thresh);
    %
    %   Runs label propagation from labeled data to unlabeled data. See
    %   reference for details.
    %
    % Reference
    % ---------
    % Xiaojin Zhu, Zoubin Ghahramani, Learning from Labeled and Unlabeled Data
    % with Label Propagation, 2002.
    %
    % Input
    % -----
    % (required)
    % [double]
    % T:    The n-by-n weighted network, aka. the trasition matrix T in the paper.
    %
    % [double]
    % Y:    The n-by-c initial label distribution matrix, where c is the number
    %       of labels (classes).
    %       Y_ij = 1  if i is labeled j
    %              0  otherwise
    %
    % (optional)
    % [double]
    % thresh:   The stop criterion.
    %           default: 0.01
    %
    % Output
    % ------
    % [double]
    % L:    The resulting label distribution

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_labelprop:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        thresh = 0.01;
    end

    % T
    validateattributes(T, {'double'}, {'nonempty'}, '', 'T', 1);
    n = size(T, 1);

    % Y
    validateattributes(Y, {'double'}, {'nrows', n}, '', 'Y', 2);
    c = size(Y, 2);

    % thresh
    validateattributes(thresh, {'double'}, {'positive'}, '', 'thresh', 3);
    % }}}

    % Locate labeled data
    li = any(Y, 2);

    while true
        % Propagate
        Yn = T * Y;

        % Row-normalize
        S = sum(Yn, 2);
        S(S == 0) = 1;
        S = S * ones(1, size(Y, 2));
        Yn = Yn ./ S;

        % Clamp the labeled data
        Yn(li, :) = Y(li, :);

        residule = Y - Yn;
        if max(residule(:)) < thresh
            L = Yn;
            break;
        else
            Y = Yn;
        end
    end
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 12:48:48 PM E
